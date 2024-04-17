#pragma description FFXIV character creator data 

#include <type/time.pat>


import std.mem;

using FFXIVColor = u8;
using FFXIVid = u8;

enum Race : u8 {
    Hyur = 1,
    Elzen,
    Lalafell,
    Miquote,
    Roegadyn,
    AuRa,
    Hrothgar,
    Viera
};

enum Gender : u8 {
    male,
    female
};

enum Age : u8 {
    normal = 1,
    old = 3,
    young = 4
};

enum Subrace : u8 {
    Midlander = 1,
    Highlander,
    Wildwood,
    Duskwigth,
    Plainsfolk,
    Dunesfolk,
    Seekers_of_the_Sun,
    Keepers_of_the_Moon,
    Sea_Wolves,
    Hellsguard,
    Raen,
    Xaela,
    Helions,
    The_Lost,
    Rava,
    Veena
};

bitfield LightDarkColor {
    unsigned color: 7;
    bool dark: 1;
};

bitfield EyeShape {
    unsigned shape: 7;
    bool small_iris: 1;
};

bitfield FacePaint {
    unsigned paint_id: 7;
    bool reversed: 1;
};

bitfield FaceFeatures {
    bool feature_1: 1;
    bool feature_2: 1;
    bool feature_3: 1;
    bool feature_4: 1;
    bool feature_5: 1;
    bool special_right: 1 [[comment("Either Ear Clasp, Limbal Ring or Tattoo depending on race.")]]; //ear_clasp__limbal_ring__tattoo
    bool special_left: 1 [[comment("Either Ear Clasp, Limbal Ring or Tattoo depending on race.")]]; 
    bool feature_8: 1;
};

struct CharacterData {
    u32 header;
    u32 file_version;
    u32 checksum; // maybe?
    u32 _space1;
    
    Race race;
    Gender gender;
    Age age;
    u8 height_pct;
    Subrace subrace;
    FFXIVid face_id;
    FFXIVid hair;
    match (race){
        (Race::Hrothgar): bool enable_fur_pattern;
        (_): bool enable_hair_highlights;
    }
    FFXIVColor skin_tone;
    FFXIVColor right_eye_color;
    FFXIVColor hair_color;
    match (race){
        (Race::Hrothgar): FFXIVColor pattern_fur_color;
        (_): FFXIVColor hair_highlights_color;
    }
    FaceFeatures facial_features;
    match (race){
        (Race::AuRa): FFXIVColor limbal_ring_color;
        (Subrace::Wildwood): FFXIVColor ear_clasp_color;
        (Subrace::Keepers_of_the_Moon & Gender::female): FFXIVColor ear_clasp_color;
        (_): FFXIVColor tattoo_color;
    }
    FFXIVid eyebrows;
    FFXIVColor left_eye_color;
    EyeShape eyes_shape;
    FFXIVid nose;
    FFXIVid jaw;
    FFXIVid mouth;
    match (race){
        (Race::Hrothgar): FFXIVid fur_pattern_id;
        (_): LightDarkColor lips_color;
    }
    match (race){
        (Race::Hyur | Race::Roegadyn): u8 muscle_tone_pct;
        (Race::Miquote | Race::AuRa | Race::Hrothgar): u8 tail_length_pct;
        (Race::Lalafell | Race::Elzen | Race::Viera): u8 ear_length_pct;
        (_): u8 _tbd;
    }
    FFXIVid tail_shape;
    u8 bust_pct;
    FacePaint face_paint;
    LightDarkColor face_paint_color;
    FFXIVid voice;
    u8 _space2;

    // The timestamp when the preset was created.
    type::time32_t timestamp;
    char comment[40];
};

CharacterData character @ 0x00;