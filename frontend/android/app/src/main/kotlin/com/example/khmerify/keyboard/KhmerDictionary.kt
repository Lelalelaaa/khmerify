package com.example.khmerify.keyboard

import android.content.Context
import org.json.JSONArray
import java.util.Locale

object KhmerDictionary {

    private val dictionary = linkedMapOf<String, MutableList<String>>()
    private var isInitialized = false

    fun initialize(context: Context) {
        if (isInitialized) return

        try {
            val entries = JSONArray(
                context.assets.open("common_words_with_romanization.json")
                    .bufferedReader(Charsets.UTF_8)
                    .use { it.readText() }
            )

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
            isInitialized = true
        } catch (_: Exception) {
            dictionary.clear()
        }
    }

    // Phonetic consonant and vowel mappings (ported from Rule Engine)
    private val consonants = mapOf(
        "kh" to "ខ", "ng" to "ង", "ch" to "ច", "nh" to "ញ", "th" to "ថ",
        "k" to "ក", "g" to "គ", "j" to "ជ", "t" to "ត", "d" to "ដ",
        "n" to "ន", "b" to "ប", "p" to "ផ", "m" to "ម", "y" to "យ",
        "r" to "រ", "l" to "ល", "v" to "វ", "s" to "ស", "h" to "ហ"
    )

    private val vowels = mapOf(
        "ei" to "ី", "ou" to "ូ", "ea" to "ា", "ae" to "ែ", "av" to "ៅ",
        "a" to "អ", "u" to "ុ", "o" to "ោ"
    )

    private const val JERNG = "\u17D2" // Subscript consonant connector (្)

    /**
     * Converts arbitrary romanized text to Khmer script via phonetic pattern rules
     */
    fun convertByPattern(text: String): String {
        val lower = text.lowercase()
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
     * Look up candidates for the current typed prefix
     */
    fun getCandidates(query: String): List<String> {
        val clean = query.trim().lowercase()
        if (clean.isEmpty()) return emptyList()

        val results = mutableListOf<String>()

        // 1. Exact match from predefined dictionary
        dictionary[clean]?.let { results.addAll(it) }

        // 2. Prefix matches from dictionary (e.g. typing "kn" suggests "ខ្ញុំ")
        for ((key, values) in dictionary) {
            if (key != clean && key.startsWith(clean)) {
                results.addAll(values)
            }
        }

        // 3. Fallback to phonetic rule engine conversion
        val patternKhmer = convertByPattern(clean)
        if (patternKhmer.isNotEmpty() && !results.contains(patternKhmer)) {
            results.add(patternKhmer)
        }

        return results.distinct().take(10)
    }
}
