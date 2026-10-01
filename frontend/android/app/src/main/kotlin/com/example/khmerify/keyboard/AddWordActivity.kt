package com.example.khmerify.keyboard

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.os.Bundle
import android.text.InputType
import android.util.TypedValue
import android.widget.EditText
import android.widget.LinearLayout
import org.json.JSONArray
import org.json.JSONObject

class AddWordActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val initialRomanized = intent.getStringExtra("romanized_word") ?: ""
        
        val romanizedInput = EditText(this).apply {
            hint = "Romanized spelling"
            setText(initialRomanized)
            inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
            setSingleLine(true)
        }
        val khmerInput = EditText(this).apply {
            hint = "Khmer translation"
            inputType = InputType.TYPE_CLASS_TEXT
            setSingleLine(true)
        }
        
        val form = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dpToPx(20), dpToPx(8), dpToPx(20), 0)
            addView(romanizedInput)
            addView(khmerInput)
        }
        
        val dialog = AlertDialog.Builder(this)
            .setTitle("Add to your library")
            .setView(form)
            .setNegativeButton("Cancel") { _, _ -> finish() }
            .setPositiveButton("Add", null)
            .setOnCancelListener { finish() }
            .create()
            
        dialog.setCanceledOnTouchOutside(false)
        dialog.setOnShowListener {
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener {
                val romanized = romanizedInput.text.toString().trim()
                val khmer = khmerInput.text.toString().trim()
                if (romanized.isEmpty() || khmer.isEmpty()) {
                    khmerInput.error = "Both fields are required"
                    return@setOnClickListener
                }
                saveLibraryWord(romanized, khmer)
                dialog.dismiss()
                finish()
            }
        }
        dialog.show()
        khmerInput.requestFocus()
    }
    
    private fun dpToPx(dp: Int): Int =
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
