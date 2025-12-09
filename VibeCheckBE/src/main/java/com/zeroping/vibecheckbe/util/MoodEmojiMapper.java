package com.zeroping.vibecheckbe.util;

import java.util.HashMap;
import java.util.Map;

public class MoodEmojiMapper {
    
    private static final Map<String, String> EMOJI_MAP = new HashMap<>();
    private static final Map<String, String> COLOR_MAP = new HashMap<>();
    
    static {
        // Positive moods
        EMOJI_MAP.put("excellent", "😄");
        EMOJI_MAP.put("good", "🙂");
        EMOJI_MAP.put("happy", "😊");
        EMOJI_MAP.put("great", "😃");
        EMOJI_MAP.put("amazing", "🤩");
        
        // Neutral moods
        EMOJI_MAP.put("okay", "😐");
        EMOJI_MAP.put("neutral", "😑");
        EMOJI_MAP.put("meh", "😕");
        EMOJI_MAP.put("fine", "🙂");
        
        // Negative moods
        EMOJI_MAP.put("bad", "😞");
        EMOJI_MAP.put("terrible", "😢");
        EMOJI_MAP.put("sad", "😔");
        EMOJI_MAP.put("awful", "😭");
        
        // Stressed/Anxious moods
        EMOJI_MAP.put("stressed", "😰");
        EMOJI_MAP.put("anxious", "😟");
        EMOJI_MAP.put("worried", "😨");
        EMOJI_MAP.put("overwhelmed", "😵");
        
        // Angry moods
        EMOJI_MAP.put("angry", "😠");
        EMOJI_MAP.put("frustrated", "😤");
        EMOJI_MAP.put("annoyed", "😒");
        EMOJI_MAP.put("mad", "🤬");
        
        // Color mappings
        COLOR_MAP.put("excellent", "#2E7D32");  // Dark green
        COLOR_MAP.put("good", "#66BB6A");       // Light green
        COLOR_MAP.put("happy", "#4CAF50");      // Green
        COLOR_MAP.put("great", "#81C784");      // Light green
        COLOR_MAP.put("amazing", "#A5D6A7");    // Very light green
        
        COLOR_MAP.put("okay", "#FFC107");       // Yellow
        COLOR_MAP.put("neutral", "#FFEB3B");   // Light yellow
        COLOR_MAP.put("meh", "#FFD54F");       // Pale yellow
        COLOR_MAP.put("fine", "#FFF176");     // Very light yellow
        
        COLOR_MAP.put("bad", "#FF9800");       // Orange
        COLOR_MAP.put("terrible", "#D32F2F");  // Red
        COLOR_MAP.put("sad", "#F57C00");      // Dark orange
        COLOR_MAP.put("awful", "#C62828");     // Dark red
        
        COLOR_MAP.put("stressed", "#F57C00");  // Dark orange
        COLOR_MAP.put("anxious", "#FF6F00");   // Orange
        COLOR_MAP.put("worried", "#E65100");  // Deep orange
        COLOR_MAP.put("overwhelmed", "#BF360C"); // Very dark orange
        
        COLOR_MAP.put("angry", "#C62828");     // Dark red
        COLOR_MAP.put("frustrated", "#D32F2F"); // Red
        COLOR_MAP.put("annoyed", "#E53935");   // Bright red
        COLOR_MAP.put("mad", "#B71C1C");       // Very dark red
    }
    
    /**
     * Gets the emoji for a mood name (case-insensitive)
     */
    public static String getEmoji(String moodName) {
        if (moodName == null) return "😐";
        return EMOJI_MAP.getOrDefault(moodName.toLowerCase().trim(), "😐");
    }
    
    /**
     * Gets the color code for a mood name (case-insensitive)
     */
    public static String getColorCode(String moodName) {
        if (moodName == null) return "#FFC107";
        return COLOR_MAP.getOrDefault(moodName.toLowerCase().trim(), "#FFC107");
    }
    
    /**
     * Checks if a mood name has a mapped emoji
     */
    public static boolean hasMapping(String moodName) {
        if (moodName == null) return false;
        return EMOJI_MAP.containsKey(moodName.toLowerCase().trim());
    }
}

