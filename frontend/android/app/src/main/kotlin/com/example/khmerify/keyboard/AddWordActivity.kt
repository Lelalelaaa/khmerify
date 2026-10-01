package com.example.khmerify.keyboard

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Bundle
import android.text.InputType
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject

class AddWordActivity : Activity() {

    private val inkColor = Color.parseColor("#111111")
    private val paperColor = Color.parseColor("#FFFFFCF7")
    private val yellowColor = Color.parseColor("#FFD21F")
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val initialRomanized = intent.getStringExtra("romanized_word") ?: ""

        val root = LinearLayout(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#80000000"))
            setPadding(dp(20), dp(20), dp(20), dp(20))
            setOnClickListener { finish() }
        }

        val dialogBox = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            background = createBorderDrawable(paperColor, inkColor, dp(14).toFloat(), dp(2))
            setPadding(dp(24), dp(24), dp(24), dp(24))
            setOnClickListener { } // Consume clicks so it doesn't close when tapping the box
        }

        val title = TextView(this).apply {
            text = "Add to your library"
            setTextColor(inkColor)
            textSize = 20f
            setTypeface(null, Typeface.BOLD)
            setPadding(0, 0, 0, dp(16))
        }
        
        val romanizedInput = createStyledEditText("Romanized spelling", initialRomanized)
        romanizedInput.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
        
        val khmerInput = createStyledEditText("Khmer translation", "")
        khmerInput.inputType = InputType.TYPE_CLASS_TEXT
        
        val buttonsLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.END
            setPadding(0, dp(24), 0, 0)
        }
        
        val btnCancel = Button(this).apply {
            text = "Cancel"
            setTextColor(inkColor)
            background = createBorderDrawable(Color.TRANSPARENT, inkColor, dp(12).toFloat(), dp(2))
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                marginEnd = dp(8)
            }
            isAllCaps = false
            setTypeface(null, Typeface.BOLD)
            setOnClickListener { finish() }
        }
        
        val btnAdd = Button(this).apply {
            text = "Add"
            setTextColor(inkColor)
            background = createBorderDrawable(yellowColor, inkColor, dp(12).toFloat(), dp(2))
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                marginStart = dp(8)
            }
            isAllCaps = false
            setTypeface(null, Typeface.BOLD)
            setOnClickListener {
                val r = romanizedInput.text.toString().trim()
                val k = khmerInput.text.toString().trim()
                if (r.isEmpty() || k.isEmpty()) {
                    khmerInput.error = "Both fields are required"
                    return@setOnClickListener
                }
                saveLibraryWord(r, k)
                finish()
            }
        }
        
        buttonsLayout.addView(btnCancel)
        buttonsLayout.addView(btnAdd)
        
        dialogBox.addView(title)
        dialogBox.addView(romanizedInput)
        dialogBox.addView(khmerInput)
        dialogBox.addView(buttonsLayout)
        
        root.addView(dialogBox)
        setContentView(root)
        
        khmerInput.requestFocus()
    }
    
    private fun createStyledEditText(hintText: String, textValue: String): EditText {
        return EditText(this).apply {
            hint = hintText
            setHintTextColor(Color.parseColor("#6E6B66"))
            setText(textValue)
            setTextColor(inkColor)
            setSingleLine(true)
            val pad = dp(14)
            setPadding(pad, pad, pad, pad)
            background = createBorderDrawable(Color.WHITE, inkColor, dp(12).toFloat(), dp(2))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = dp(12)
            }
        }
    }
    
    private fun createBorderDrawable(fillColor: Int, strokeColor: Int, radius: Float, strokeWidth: Int): GradientDrawable {
        return GradientDrawable().apply {
            setColor(fillColor)
            setStroke(strokeWidth, strokeColor)
            cornerRadius = radius
        }
    }
    
    private fun dp(dp: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp.toFloat(), resources.displayMetrics).toInt()
        
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
    }
}
