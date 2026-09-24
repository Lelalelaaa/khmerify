package com.example.khmerify.keyboard

import android.content.Context
import android.graphics.Color
import android.inputmethodservice.InputMethodService
import android.util.TypedValue
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.example.khmerify.R

class KhmerifyKeyboardService : InputMethodService() {

    private val composingBuffer = StringBuilder()
    private lateinit var candidateContainer: LinearLayout
    private lateinit var tvComposingPreview: TextView
    private lateinit var keyboardRows: LinearLayout

    private var isShifted = false
    private var isSymbols = false

    override fun onCreateInputView(): View {
        KhmerDictionary.initialize(this)
        val view = layoutInflater.inflate(R.layout.keyboard_view, null)
        candidateContainer = view.findViewById(R.id.candidate_container)
        tvComposingPreview = view.findViewById(R.id.tv_composing_preview)
        keyboardRows = view.findViewById(R.id.keyboard_rows)

        buildKeyboard()
        return view
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        composingBuffer.clear()
        isShifted = false
        isSymbols = false
        updateCandidates()
        buildKeyboard()
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
        val candidates = KhmerDictionary.getCandidates(query)

        if (candidates.isNotEmpty()) {
            // Auto-commit top candidate on space (like Gboard Pinyin)
            commitWord(candidates.first())
            currentInputConnection?.commitText(" ", 1)
        } else if (composingBuffer.isNotEmpty()) {
            currentInputConnection?.commitText("$composingBuffer ", 1)
            composingBuffer.clear()
            updateCandidates()
        } else {
            currentInputConnection?.commitText(" ", 1)
        }
    }

    private fun onEnter() {
        if (composingBuffer.isNotEmpty()) {
            val candidates = KhmerDictionary.getCandidates(composingBuffer.toString())
            if (candidates.isNotEmpty()) {
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
    }

    // --- Dynamic Keyboard Layout Generator ---

    private fun buildKeyboard() {
        keyboardRows.removeAllViews()

        val rows: List<List<String>> = if (isSymbols) {
            listOf(
                listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
                listOf("@", "#", "$", "%", "&", "-", "+", "(", ")", "/"),
                listOf("=", "*", "\"", "'", ":", ";", "!", "?", "DEL"),
                listOf("ABC", "🌐", "SPACE", "ENTER")
            )
        } else {
            val r1 = listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p")
            val r2 = listOf("a", "s", "d", "f", "g", "h", "j", "k", "l")
            val r3 = listOf("SHIFT", "z", "x", "c", "v", "b", "n", "m", "DEL")
            val r4 = listOf("?123", "🌐", "SPACE", "ENTER")

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

                    val isSpecial = key in listOf("DEL", "ENTER", "SHIFT", "?123", "ABC", "🌐")
                    setBackgroundResource(
                        if (isSpecial) R.drawable.key_special_background else R.drawable.key_background
                    )

                    val weight = when (key) {
                        "SPACE" -> 4.0f
                        "ENTER" -> 1.8f
                        "DEL" -> 1.5f
                        "SHIFT", "?123", "ABC" -> 1.4f
                        "🌐" -> 0.9f
                        else -> 1.0f
                    }

                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, weight).apply {
                        setMargins(dpToPx(2), 0, dpToPx(2), 0)
                    }

                    setOnClickListener {
                        handleKeyPress(key)
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
            "🌐" -> {
                // Switch keyboard picker
                val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                imm?.showInputMethodPicker()
            }
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
}
