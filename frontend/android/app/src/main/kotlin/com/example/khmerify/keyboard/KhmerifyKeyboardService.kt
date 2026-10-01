package com.example.khmerify.keyboard

import android.content.Context
import android.app.AlertDialog
import android.graphics.Color
import android.inputmethodservice.InputMethodService
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import android.text.InputType
import org.json.JSONArray
import org.json.JSONObject
import com.example.khmerify.R

class KhmerifyKeyboardService : InputMethodService() {

    private val composingBuffer = StringBuilder()
    private lateinit var candidateContainer: LinearLayout
    private lateinit var tvComposingPreview: TextView
    private lateinit var keyboardRows: LinearLayout

    private var isShifted = false
    private var isSymbols = false
        private val deleteHandler = Handler(Looper.getMainLooper())
    private var repeatDelete = false
    private var didRepeatDelete = false
    private val deleteRunnable = object : Runnable {
        override fun run() {
            if (!repeatDelete) return
            didRepeatDelete = true
            onBackspace()
            deleteHandler.postDelayed(this, 55L)
        }
    }

    override fun onCreateInputView(): View? {
        try {
            KhmerDictionary.initialize(this)
            val view = layoutInflater.inflate(R.layout.keyboard_view, null)
            candidateContainer = view.findViewById(R.id.candidate_container)
            tvComposingPreview = view.findViewById(R.id.tv_composing_preview)
            keyboardRows = view.findViewById(R.id.keyboard_rows)

            buildKeyboard()
            return view
        } catch (e: Exception) {
            android.util.Log.e("KHMER_ERROR", "onCreateInputView crashed", e)
            return null
        }
    }

    override fun onEvaluateInputViewShown(): Boolean {
        super.onEvaluateInputViewShown()
        return true
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        try {
            super.onStartInputView(info, restarting)
            KhmerDictionary.reload(this)
            composingBuffer.clear()
            isShifted = false
            isSymbols = false
            updateCandidates()
            buildKeyboard()
        } catch (e: Exception) {
            android.util.Log.e("KHMER_ERROR", "onStartInputView crashed", e)
        }
    }

    // --- Keystroke Handlers ---

    private fun onCharTyped(c: Char) {
        composingBuffer.append(c)
        updateComposingText()
        updateCandidates()
    }

    private fun onBackspace() {
        if (composingBuffer.isNotEmpty()) {
            composingBuffer.deleteCharAt(composingBuffer.length - 1)
            updateComposingText()
            updateCandidates()
        } else {
            // Delete character in target app
            currentInputConnection?.deleteSurroundingText(1, 0)
        }
    }

    private fun onSpace() {
        val query = composingBuffer.toString()
        val candidates = KhmerDictionary.getExactCandidates(query)

        if (!candidates.isNullOrEmpty()) {
            commitWord(candidates.first())
        } else if (composingBuffer.isNotEmpty()) {
            currentInputConnection?.commitText(composingBuffer.toString(), 1)
            composingBuffer.clear()
            updateCandidates()
        } else {
            currentInputConnection?.commitText(" ", 1)
        }
    }

    private fun onEnter() {
        if (composingBuffer.isNotEmpty()) {
            val candidates = KhmerDictionary.getExactCandidates(composingBuffer.toString())
            if (!candidates.isNullOrEmpty()) {
                commitWord(candidates.first())
            } else {
                currentInputConnection?.commitText(composingBuffer.toString(), 1)
                composingBuffer.clear()
                updateCandidates()
            }
        }

        val ic = currentInputConnection ?: return
        val currentInfo = currentInputEditorInfo

        if (currentInfo != null && currentInfo.imeOptions and EditorInfo.IME_MASK_ACTION != EditorInfo.IME_ACTION_NONE) {
            val action = currentInfo.imeOptions and EditorInfo.IME_MASK_ACTION
            ic.performEditorAction(action)
        } else {
            ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER))
            ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER))
        }
    }

    private fun commitWord(word: String) {
        val ic: InputConnection = currentInputConnection ?: return
        ic.commitText(word, 1)
        composingBuffer.clear()
        updateCandidates()
    }

    private fun updateComposingText() {
        val ic: InputConnection = currentInputConnection ?: return
        if (composingBuffer.isNotEmpty()) {
            // Display composing underline in target app
            ic.setComposingText(composingBuffer.toString(), 1)
            tvComposingPreview.text = composingBuffer.toString()
        } else {
            ic.finishComposingText()
            tvComposingPreview.text = "🇰🇭"
        }
    }

    private fun updateCandidates() {
        candidateContainer.removeAllViews()
        val query = composingBuffer.toString()
        if (query.isEmpty()) {
            tvComposingPreview.text = "🇰🇭"
            return
        }

        val suggestions = KhmerDictionary.getCandidates(query)
        for (word in suggestions) {
            val chip = TextView(this).apply {
                text = word
                textSize = 17f
                setTextColor(Color.WHITE)
                setBackgroundResource(R.drawable.candidate_background)
                setPadding(dpToPx(14), dpToPx(6), dpToPx(14), dpToPx(6))
                val params = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(dpToPx(4), 0, dpToPx(4), 0)
                }
                layoutParams = params

                setOnClickListener {
                    commitWord(word)
                }
            }
            candidateContainer.addView(chip)
        }

        if (KhmerDictionary.getExactCandidates(query).isNullOrEmpty()) {
            val addAction = TextView(this).apply {
                text = "+ Add"
                textSize = 14f
                setTextColor(Color.WHITE)
                setBackgroundResource(R.drawable.key_special_background)
                setPadding(dpToPx(12), dpToPx(6), dpToPx(12), dpToPx(6))
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(dpToPx(4), 0, dpToPx(4), 0)
                }
                setOnClickListener { showAddWordDialog(query) }
            }
            candidateContainer.addView(addAction)
        }
    }

    private fun showAddWordDialog(query: String) {
        val intent = android.content.Intent(this, AddWordActivity::class.java).apply {
            addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("romanized_word", query)
        }
        startActivity(intent)
    }

    private fun replaceSelection(input: EditText, replacement: String) {
        val text = input.text
        val start = input.selectionStart.coerceIn(0, text.length)
        val end = input.selectionEnd.coerceIn(0, text.length)
        val selectionStart = minOf(start, end)
        text.replace(selectionStart, maxOf(start, end), replacement)
        input.setSelection(selectionStart + replacement.length)
    }

    private fun saveLibraryWord(romanized: String, khmer: String) {
        val preferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val savedLibrary = preferences.getString("flutter.khmerify_library", null)
        val entries = if (savedLibrary != null) {
            JSONArray(savedLibrary)
        } else {
            assets.open("common_words_with_romanization.json")
                .bufferedReader(Charsets.UTF_8).use { JSONArray(it.readText()) }
        }
        entries.put(
            JSONObject()
                .put("romanized", romanized)
                .put("khmer", khmer)
                .put("aliases", JSONArray())
        )
        preferences.edit()
            .putString("flutter.khmerify_library", entries.toString())
            .apply()
        KhmerDictionary.reload(this)
        commitWord(khmer)
    }

    // --- Dynamic Keyboard Layout Generator ---

    private fun buildKeyboard() {
        keyboardRows.removeAllViews()

        val rows: List<List<String>> = if (isSymbols) {
            listOf(
                listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
                listOf("@", "#", "$", "%", "&", "-", "+", "(", ")", "/"),
                listOf("=", "*", "\"", "'", ":", ";", "!", "?", "DEL"),
                listOf("ABC", "ADD", "SPACE", "ENTER")
            )
        } else {
            val r1 = listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p")
            val r2 = listOf("a", "s", "d", "f", "g", "h", "j", "k", "l")
            val r3 = listOf("SHIFT", "z", "x", "c", "v", "b", "n", "m", "DEL")
            val r4 = listOf("?123", "ADD", "SPACE", "ENTER")

            if (isShifted) {
                listOf(
                    r1.map { it.uppercase() },
                    r2.map { it.uppercase() },
                    listOf("SHIFT") + listOf("z", "x", "c", "v", "b", "n", "m").map { it.uppercase() } + listOf("DEL"),
                    r4
                )
            } else {
                listOf(r1, r2, r3, r4)
            }
        }

        for (row in rows) {
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    dpToPx(52)
                ).apply { setMargins(0, dpToPx(3), 0, dpToPx(3)) }
                gravity = Gravity.CENTER
            }

            for (key in row) {
                val button = Button(this).apply {
                    text = key
                    textSize = if (key.length > 2) 13f else 17f
                    setTextColor(Color.WHITE)
                    isAllCaps = false
                    minHeight = 0
                    minimumHeight = 0
                    stateListAnimator = null
                    setPadding(0, 0, 0, 0)

                    val isSpecial = key in listOf("DEL", "ENTER", "SHIFT", "?123", "ABC", "ADD")
                    setBackgroundResource(
                        if (isSpecial) R.drawable.key_special_background else R.drawable.key_background
                    )

                    val weight = when (key) {
                        "SPACE" -> 4.0f
                        "ENTER" -> 1.8f
                        "DEL" -> 1.5f
                        "SHIFT", "?123", "ABC", "ADD" -> 1.4f
                        else -> 1.0f
                    }

                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, weight).apply {
                        setMargins(dpToPx(2), 0, dpToPx(2), 0)
                    }

                    setOnClickListener {
                        if (key == "DEL") {
                            if (!didRepeatDelete) onBackspace()
                            didRepeatDelete = false
                        } else {
                            handleKeyPress(key)
                        }
                    }

                    if (key == "DEL") {
                        setOnTouchListener { _, event ->
                            when (event.action) {
                                MotionEvent.ACTION_DOWN -> {
                                    didRepeatDelete = false
                                    repeatDelete = true
                                    deleteHandler.postDelayed(deleteRunnable, 350L)
                                }
                                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                                    repeatDelete = false
                                    deleteHandler.removeCallbacks(deleteRunnable)
                                }
                            }
                            false
                        }
                    }
                }
                rowLayout.addView(button)
            }
            keyboardRows.addView(rowLayout)
        }
    }

    private fun handleKeyPress(key: String) {
        when (key) {
            "DEL" -> onBackspace()
            "SPACE" -> onSpace()
            "ENTER" -> onEnter()
            "SHIFT" -> {
                isShifted = !isShifted
                buildKeyboard()
            }
            "?123" -> {
                isSymbols = true
                buildKeyboard()
            }
            "ABC" -> {
                isSymbols = false
                buildKeyboard()
            }
            "ADD" -> showAddWordDialog(composingBuffer.toString())
            else -> {
                val char = key[0]
                onCharTyped(char)
                if (isShifted) {
                    isShifted = false
                    buildKeyboard()
                }
            }
        }
    }

    private fun dpToPx(dp: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp.toFloat(), resources.displayMetrics).toInt()

    override fun onDestroy() {
        repeatDelete = false
        deleteHandler.removeCallbacks(deleteRunnable)
        super.onDestroy()
    }
}
