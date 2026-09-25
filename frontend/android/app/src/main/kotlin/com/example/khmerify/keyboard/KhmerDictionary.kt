package com.example.khmerify.keyboard

import android.content.Context
import org.json.JSONArray
import java.util.Locale

object KhmerDictionary {

    private val dictionary = linkedMapOf<String, MutableList<String>>()
    private var isInitialized = false

    fun initialize(context: Context) {
        if (isInitialized) return
        loadDictionary(context)
        isInitialized = true
    }

    fun reload(context: Context) {
        loadDictionary(context)
        isInitialized = true
    }

    private fun loadDictionary(context: Context) {
        dictionary.clear()
        try {
            val sharedLibrary = context
                .getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .getString("flutter.khmerify_library", null)
            val dictionaryJson = sharedLibrary ?: context.assets.open(
                "common_words_with_romanization.json"
            ).bufferedReader(Charsets.UTF_8).use { it.readText() }
            addEntries(JSONArray(dictionaryJson))
        } catch (_: Exception) {
            dictionary.clear()
        }
    }

    private fun addEntries(entries: JSONArray) {
        for (index in 0 until entries.length()) {
            val entry = entries.getJSONObject(index)
            val word = entry.getString("khmer")
            val keys = buildList {
                add(entry.getString("romanized"))
                val aliases = entry.optJSONArray("aliases") ?: return@buildList
                for (aliasIndex in 0 until aliases.length()) {
                    add(aliases.getString(aliasIndex))
                }
            }

            for (key in keys) {
                dictionary.getOrPut(key.lowercase(Locale.ROOT)) { mutableListOf() }
                    .add(word)
            }
        }
    }

    // Keep these maps aligned with backend/engine/rule_engine.py.
    private val consonants = mapOf(
        "k" to "ក", "kh" to "ខ", "g" to "គ", "ng" to "ង", "ch" to "ច",
        "j" to "ជ", "nh" to "ញ", "t" to "ត", "th" to "ថ", "d" to "ដ",
        "n" to "ន", "b" to "ប", "p" to "ផ", "m" to "ម", "y" to "យ",
        "r" to "រ", "l" to "ល", "v" to "វ", "s" to "ស", "h" to "ហ"
    )

    private val vowels = mapOf(
        "a" to "អ", "ei" to "ី", "ei_open" to "ែ", "u" to "ុ", "o" to "ោ",
        "ou" to "ូ", "ea" to "ា", "ae" to "ែ", "av" to "ៅ"
    )

    private const val JERNG = "\u17D2" // Subscript consonant connector (្)

    /**
     * Converts arbitrary romanized text to Khmer script via phonetic pattern rules
     */
    fun convertByPattern(text: String): String {
        val lower = text.lowercase(Locale.ROOT)
        val allPatterns = (consonants + vowels).toList().sortedByDescending { it.first.length }
        val result = StringBuilder()
        var i = 0
        var lastWasConsonant = false

        while (i < lower.length) {
            var matched = false
            for ((pattern, khmerChar) in allPatterns) {
                if (lower.startsWith(pattern, i)) {
                    val isConsonant = consonants.containsKey(pattern)
                    if (isConsonant && lastWasConsonant) {
                        result.append(JERNG)
                    }
                    result.append(khmerChar)
                    i += pattern.length
                    matched = true
                    lastWasConsonant = isConsonant
                    break
                }
            }
            if (!matched) {
                result.append(lower[i])
                i++
                lastWasConsonant = false
            }
        }
        return result.toString()
    }

    /**
     * Look up candidates for the current typed prefix.
     */
    fun getCandidates(query: String): List<String> {
        val clean = query.trim().lowercase(Locale.ROOT)
        if (clean.isEmpty()) return emptyList()

        val results = mutableListOf<String>()

        // Exact seed entries always come first, matching the backend lookup.
        getExactCandidates(clean)?.let { results.addAll(it) }

        // Prefix matches from the seed dictionary (e.g. typing "kn" suggests "ខ្ញុំ").
        for ((key, values) in dictionary) {
            if (key != clean && key.startsWith(clean)) {
                results.addAll(values)
            }
        }

        return results.distinct().take(10)
    }

    /**
     * Return only approved offline seed matches for a complete romanized word.
     * Prefixes and phonetic fallbacks must not be auto-committed as translations.
     */
    fun getExactCandidates(query: String): List<String>? {
        val clean = query.trim().lowercase(Locale.ROOT)
        return dictionary[clean]?.distinct()
    }
}
