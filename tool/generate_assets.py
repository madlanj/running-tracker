import os
import json
import zlib
import struct
from datetime import date, timedelta

# Ensure directories exist
os.makedirs("assets/data", exist_ok=True)
os.makedirs("assets/images/exercises", exist_ok=True)

# 1. GENERATE 197-DAY TRAINING SCHEDULE JSON
start_date = date(2026, 11, 16)
end_date = date(2027, 5, 31)

days_id = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]

STRENGTH_A = "Upper Body & Core: Plank 3x45s, Side Plank 3x30s/sisi, Bird-Dog 3x12 reps, Deadbug 3x12 reps, Push-up 3x12 reps."
STRENGTH_B = "Lower Body Durability: Bulgarian Split Squat 3x10/kaki, Single-Leg Calf Raises 3x15/kaki, Glute Bridge 3x15 reps, Wall Sit 3x45s."
STRENGTH_C = "Hip Stability & Balance: Single-Leg Romanian Deadlift (RDL) 3x10/kaki, Clamshells 3x15/sisi, Walking Lunges 3x12 langkah, Standing Calf Raises 3x20 reps."
STRENGTH_MOBILITY = "Mobility & Foam Rolling: Peregangan dinamis hamstring, quadriceps, IT band foam rolling, ankle mobility 15 menit."
STRENGTH_RAMADHAN = "Bodyweight Tone (Sebelum tidur/sehabis lari): Plank 3x30s, Bodyweight Squat 3x12 reps, Glute Bridge 3x12 reps, Calf Raises 3x15 reps."

NUTRITION_FASTING = "Sahur: Oatmeal + telur rebus 2 butir + pisang + air kelapa/elektrolit (min. 750ml). Siang: Puasa. Buka: Air hangat + 3 butir kurma + roti/buah -> Maghrib -> Makan malam seimbang (nasi, dada ayam, sayur bayam, tempe) -> Rehidrasi min. 1.5L hingga tidur."
NUTRITION_EASY = "Pagi (05.00): Air mineral 250ml + 1/2 pisang sebelum lari -> Pasca Lari (06.15): Sarapan telur dadar + roti gandum/nasi + susu kedelai/whey. Siang: Nasi + lauk protein tinggi + sayur. Sore: Buah segar/almond. Malam: Makan malam porsi sedang, tidur cukup 7-8 jam."
NUTRITION_TEMPO = "Pagi (05.00): Air hangat + madu 1 sdm + 1 pisang (karbo cepat). Pasca Lari (06.30): Sarapan karbo + protein (Nasi uduk/oatmeal + ayam suwir + 2 telur). Siang & Malam: Asupan karbohidrat kompleks & hidrasi ekstra (tambahkan sejumput garam himalaya / tablet elektrolit)."
NUTRITION_LONGRUN = "Jumat Malam: Karbo-loading bersih (nasi/pasta + protein rendah lemak, hindari serat terlalu tinggi). Sabtu Pagi (04.45): 1 buah pisang + 300ml air. Saat Lari: Bawa botol air + 1 sachet Energy Gel diminum di km 8-10. Pasca Lari: Air kelapa murni dingin + sarapan komplit tinggi protein & karbohidrat."
NUTRITION_REST = "Fokus Pemulihan: Pola makan bersih 3x sehari. Kurangi gula olahan, perbanyak air mineral 2.5L, sayuran hijau, dan buah antioksidan (jeruk/pepaya) untuk meredakan inflamasi otot."
NUTRITION_RAMADHAN_POST = "Buka (18.00): Air kelapa + 3 kurma + 1 potong roti/pisang. Tarawih (19.15). Lari (20.45). Pasca Lari (21.30): Nasi + ayam bakar/telur/tahu + sayur sup. Minum air berkala 1.5L hingga tidur jam 23.00. Sahur: Nasi/oat + protein + pisang + banyak air."

schedule_items = []
curr = start_date
day_count = 0
week_num = 1

lr_map = {
    1: 15.0, 2: 16.0, 3: 17.0, 4: 12.0,
    5: 16.0, 6: 17.0, 7: 18.0, 8: 13.0,
    9: 17.0, 10: 18.0, 11: 19.0, 12: 14.0,
    17: 12.0, 18: 15.0, 19: 17.0, 20: 13.0,
    21: 18.0, 22: 19.0, 23: 20.0,
    24: 17.0, 25: 21.1, 26: 15.0,
    27: 14.0, 28: 10.0
}

while curr <= end_date:
    day_count += 1
    day_idx = curr.weekday()
    if day_count > 1 and day_idx == 0:
        week_num += 1

    d_iso = curr.strftime("%Y-%m-%d")
    day_name = days_id[day_idx]

    is_ramadhan = (date(2027, 2, 8) <= curr <= date(2027, 3, 8))
    is_idul_fitri = (date(2027, 3, 9) <= curr <= date(2027, 3, 11))

    if curr < date(2027, 2, 8):
        fase = "Fase 1: Base Building"
    elif is_ramadhan:
        fase = "Fase 2: Ramadhan Maint."
    elif curr <= date(2027, 4, 25):
        fase = "Fase 3: Build & Tempo"
    elif curr <= date(2027, 5, 23):
        fase = "Fase 4: Peak Volume"
    else:
        fase = "Fase 5: Early Taper"

    if is_idul_fitri:
        status_puasa = "Libur Idul Fitri"
        is_puasa = False
    elif is_ramadhan:
        status_puasa = "Puasa Ramadhan"
        is_puasa = True
    elif day_idx == 0:
        status_puasa = "Puasa Sunnah Senin"
        is_puasa = True
    elif day_idx == 3:
        status_puasa = "Puasa Sunnah Kamis"
        is_puasa = True
    else:
        status_puasa = "Normal"
        is_puasa = False

    time_slot = ""
    category = ""
    dist_val = 0.0
    pace_target = ""
    menu_lari = ""
    menu_strength = ""
    nutrition = ""
    alt_non_fasting = ""

    if is_ramadhan:
        if day_idx == 1:
            time_slot = "20.45 - 21.30 WIB"
            category = "Easy Jog (Night)"
            dist_val = 5.0
            pace_target = "Pace 8:30 - 9:00 (Zone 2, HR < 145)"
            menu_lari = "Pemanasan jalan santai 3 menit. Lari santai 5 km sangat rileks menikmati malam. Pendinginan jalan 2 menit + stretching betis."
            menu_strength = STRENGTH_RAMADHAN
            nutrition = NUTRITION_RAMADHAN_POST
        elif day_idx == 3:
            time_slot = "20.45 - 21.30 WIB"
            category = "Easy Jog (Night)"
            dist_val = 5.0
            pace_target = "Pace 8:30 - 9:00 (Zone 2, HR < 145)"
            menu_lari = "Pemanasan dinamis 3 menit. Lari santai 5 km fokus pada irama nafas hidung (aerobik). Pendinginan jalan 2 menit."
            menu_strength = STRENGTH_RAMADHAN
            nutrition = NUTRITION_RAMADHAN_POST
        elif day_idx == 5:
            time_slot = "20.45 - 22.00 WIB"
            category = "Mini Long Run (Night)"
            dist_val = 8.0 if week_num in [14, 15, 16] else 7.0
            pace_target = "Pace 8:30 - 8:45 (Zone 2 murni)"
            menu_lari = f"Pemanasan jalan 5 menit. Lari konstan {dist_val:.1f} km di rute perumahan yang terang & aman. Bawa botol air kecil, minum setiap 2.5 km. Pendinginan jalan santai."
            menu_strength = STRENGTH_MOBILITY
            nutrition = NUTRITION_RAMADHAN_POST
        else:
            time_slot = "Istirahat"
            category = "Rest Day (Ramadhan)"
            dist_val = 0.0
            pace_target = "-"
            menu_lari = "Fokus istirahat, tilawah, dan ibadah Ramadhan. Tubuh memulihkan sel-sel otot."
            menu_strength = "Rest total / Stretching ringan 10 menit sebelum tidur."
            nutrition = "Sahur tinggi protein + serat oatmeal. Buka puasa seimbang dengan sayur dan lauk bernutrisi. Target air min. 2 Liter antara maghrib dan sahur."

    elif is_idul_fitri:
        time_slot = "Istirahat / Santai"
        category = "Libur Idul Fitri"
        dist_val = 0.0
        pace_target = "-"
        menu_lari = "Selamat Idul Fitri! Istirahat penuh bersama keluarga. Jika ingin bergerak, cukup jalan santai 20-30 menit."
        menu_strength = "Rest total."
        nutrition = "Nikmati hidangan lebaran secukupnya, jaga hidrasi air putih di sela minuman manis."

    else:
        if day_idx == 0:  # Senin
            time_slot = "Istirahat / Sore Ringan"
            category = "Rest Day & Core (Puasa)"
            dist_val = 0.0
            pace_target = "-"
            menu_lari = "REST DAY LARI. Memberikan recovery penuh bagi otot tungkai setelah Long Run akhir pekan."
            menu_strength = STRENGTH_A
            nutrition = NUTRITION_FASTING
            alt_non_fasting = "OPSI TIDAK PUASA: Easy Aerobic Run 5.0 km @ Pace 8:15 - 8:30 (05.15 WIB) + Sarapan Berenergi."
        elif day_idx == 3:  # Kamis
            time_slot = "Istirahat / Sore Ringan"
            category = "Rest Day & Mobility (Puasa)"
            dist_val = 0.0
            pace_target = "-"
            menu_lari = "REST DAY LARI. Menghindari dehidrasi saat berpuasa sunnah di hari kerja."
            menu_strength = STRENGTH_MOBILITY
            nutrition = NUTRITION_FASTING
            alt_non_fasting = "OPSI TIDAK PUASA: Easy Aerobic Run 5.0 km @ Pace 8:15 - 8:30 (05.15 WIB) + Mobilitas Kaki."
        elif day_idx == 1:  # Selasa
            time_slot = "05.15 - 06.00 WIB"
            category = "Easy Run + Strides"
            dist_val = 6.0 if fase == "Fase 1: Base Building" else (7.0 if fase == "Fase 3: Build & Tempo" else (7.5 if fase == "Fase 4: Peak Volume" else 5.0))
            pace_target = "Pace 8:15 - 8:35 (Zone 2, HR < 150 bpm)"
            menu_lari = f"Pemanasan dinamis 5 menit. Lari santai {dist_val-0.5:.1f} km di zona aerobik nyaman. Diakhiri 4x Strides akselerasi 80 meter. Pendinginan 3 menit."
            menu_strength = STRENGTH_B
            nutrition = NUTRITION_EASY
        elif day_idx == 2:  # Rabu
            time_slot = "05.15 - 06.05 WIB"
            category = "Tempo Run / Threshold"
            if fase == "Fase 1: Base Building":
                dist_val = 6.5
                tempo_km = 3.5
                tempo_pace = "Pace 6:55 - 7:05"
            elif fase == "Fase 3: Build & Tempo":
                dist_val = 7.5
                tempo_km = 4.5
                tempo_pace = "Pace 6:45 - 6:55"
            elif fase == "Fase 4: Peak Volume":
                dist_val = 8.0
                tempo_km = 5.0
                tempo_pace = "Pace 6:45 - 6:50"
            else:
                dist_val = 5.0
                tempo_km = 2.5
                tempo_pace = "Pace 7:00"
            pace_target = f"Tempo {tempo_pace} (Zone 4, HR 168-176)"
            menu_lari = f"Pemanasan jog santai 1.5 km. MAIN SET: {tempo_km:.1f} km lari stabil di {tempo_pace} (Simulasi Race Pace!). Pendinginan 1.5 km."
            menu_strength = "Peregangan statis otot betis, paha depan, dan hamstring 10 menit."
            nutrition = NUTRITION_TEMPO
        elif day_idx == 4:  # Jumat
            time_slot = "05.15 - 05.55 WIB"
            category = "Easy Recovery Run"
            dist_val = 5.0 if fase == "Fase 1: Base Building" else (6.0 if "Fase" in fase and "Taper" not in fase else 4.0)
            pace_target = "Pace 8:20 - 8:40 (Zone 2 murni, HR < 148)"
            menu_lari = f"Pemanasan 3 menit. Lari sangat santai {dist_val:.1f} km menjaga kaki tetap segar menjelang Long Run besok. Pendinginan 3 menit."
            menu_strength = STRENGTH_C
            nutrition = NUTRITION_EASY
        elif day_idx == 5:  # Sabtu
            time_slot = "05.15 - 07.45 WIB"
            category = "THE LONG RUN"
            dist_val = lr_map.get(week_num, 15.0)
            if dist_val == 21.1:
                pace_target = "Pace 7:30 - 7:45 (Simulasi Race HM Lengkap)"
                menu_lari = "RACE REHEARSAL 21.1 KM: Pakai jersey & sepatu race (Asics Novablast 5). Bawa 2-3 sachet energy gel (km 7, km 14). Lari stabil di pace 7:30-7:45!"
            elif week_num in [22, 24]:
                pace_target = "Pace 8:05 - 8:15 (Fast Finish 3 km terakhir di Pace 7:00)"
                menu_lari = f"Pemanasan 5 menit. Lari {dist_val-3:.1f} km di Pace 8:10, lalu 3 km TERAKHIR tekan ke Race Pace 7:00/km!"
            else:
                pace_target = "Pace 8:00 - 8:20 (Zone 2/MAF, HR 150-162)"
                menu_lari = f"LARI JARAK JAUH {dist_val:.1f} KM: Pemanasan 5 menit. Jaga pace ritmis dan teratur. Minum setiap 2.5 - 3 km."
            menu_strength = "Foam rolling paha, betis, dan IT Band 15 menit + elevasi kaki ke dinding 10 menit."
            nutrition = NUTRITION_LONGRUN
        elif day_idx == 6:  # Minggu
            time_slot = "Pagi / Sore Santai"
            category = "Active Recovery / Rest"
            dist_val = 0.0
            pace_target = "-"
            menu_lari = "Jalan kaki santai 30-40 menit bersama keluarga atau rest total."
            menu_strength = "Rest total."
            nutrition = NUTRITION_REST

    schedule_items.append({
        "id": day_count,
        "date_iso": d_iso,
        "week_number": week_num,
        "day_of_week": day_name,
        "phase": fase,
        "default_status": status_puasa,
        "default_category": category,
        "default_distance": dist_val,
        "default_pace": pace_target,
        "default_time": time_slot,
        "run_menu": menu_lari,
        "alt_non_fasting_menu": alt_non_fasting,
        "strength_menu": menu_strength,
        "nutrition_menu": nutrition,
        "is_puasa_default": is_puasa
    })
    curr += timedelta(days=1)

with open("assets/data/training_schedule.json", "w", encoding="utf-8") as f:
    json.dump(schedule_items, f, indent=2, ensure_ascii=False)

print(f"Schedule JSON generated: {len(schedule_items)} days in assets/data/training_schedule.json")

# 2. GENERATE HIGH-CLARITY PNG EXERCISE ILLUSTRATIONS
# Using pure Python PNG rasterizer
def create_canvas(width, height, bg_color):
    return [[bg_color for _ in range(width)] for _ in range(height)]

def draw_rect(canvas, x1, y1, x2, y2, color):
    h = len(canvas)
    w = len(canvas[0])
    for y in range(max(0, y1), min(h, y2)):
        for x in range(max(0, x1), min(w, x2)):
            canvas[y][x] = color

def draw_circle(canvas, cx, cy, radius, color):
    h = len(canvas)
    w = len(canvas[0])
    r2 = radius * radius
    for y in range(max(0, cy - radius), min(h, cy + radius + 1)):
        for x in range(max(0, cx - radius), min(w, cx + radius + 1)):
            if (x - cx)**2 + (y - cy)**2 <= r2:
                canvas[y][x] = color

def draw_line(canvas, x1, y1, x2, y2, color, thickness=3):
    h = len(canvas)
    w = len(canvas[0])
    dx = abs(x2 - x1)
    dy = abs(y2 - y1)
    sx = 1 if x1 < x2 else -1
    sy = 1 if y1 < y2 else -1
    err = dx - dy
    cx, cy = x1, y1
    r = thickness // 2
    while True:
        draw_circle(canvas, cx, cy, r, color)
        if cx == x2 and cy == y2:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            cx += sx
        if e2 < dx:
            err += dx
            cy += sy

def canvas_to_png(canvas):
    h = len(canvas)
    w = len(canvas[0])
    raw = bytearray()
    for row in canvas:
        raw.append(0)
        for r, g, b in row:
            raw.extend([r, g, b])
    
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)
    ihdr_chunk = struct.pack('>I', len(ihdr)) + b'IHDR' + ihdr + struct.pack('>I', zlib.crc32(b'IHDR' + ihdr))
    
    compressed = zlib.compress(bytes(raw), 9)
    idat_chunk = struct.pack('>I', len(compressed)) + b'IDAT' + compressed + struct.pack('>I', zlib.crc32(b'IDAT' + compressed))
    
    iend = struct.pack('>I', 0) + b'IEND' + struct.pack('>I', zlib.crc32(b'IEND'))
    return b'\x89PNG\r\n\x1a\n' + ihdr_chunk + idat_chunk + iend

exercises = [
    ("bulgarian_split_squat", "Bulgarian Split Squat", "Leg & Glute Stability"),
    ("calf_raises", "Single-Leg Calf Raises", "Soleus & Achilles Strength"),
    ("glute_bridge", "Glute Bridge", "Glute Activation & Hip Thrust"),
    ("side_plank", "Side Plank + Leg Raise", "Gluteus Medius (Anti-ITBS)"),
    ("plank_taps", "Plank + Shoulder Taps", "Anti-Rotational Core"),
    ("bird_dog", "Bird-Dog Reach", "Cross-Body Sling Stability"),
    ("single_leg_rdl", "Single-Leg RDL", "Hamstrings & Ankle Balance"),
    ("wall_sit", "Wall Sit Isometric", "Patellar Tendon & Quad Burn")
]

# Brand colors
BG = (245, 247, 250)         # Soft off-white
NAVY = (27, 54, 93)          # JAKIM Navy
ACCENT = (0, 168, 150)       # Athletic teal/mint
ORANGE = (242, 100, 25)      # Energy orange
DARK = (40, 44, 52)          # Figure color
BENCH = (180, 190, 200)      # Bench / floor

W, H = 400, 300

for filename, title, subtitle in exercises:
    c = create_canvas(W, H, BG)
    
    # Header card banner
    draw_rect(c, 0, 0, W, 50, NAVY)
    draw_rect(c, 0, 48, W, 52, ACCENT)
    
    # Ground baseline
    draw_line(c, 30, 250, 370, 250, BENCH, thickness=4)
    
    # Diagram depending on exercise
    if filename == "bulgarian_split_squat":
        # Bench on right
        draw_rect(c, 270, 180, 340, 250, BENCH)
        # Head
        draw_circle(c, 160, 95, 16, DARK)
        # Torso
        draw_line(c, 160, 111, 165, 175, DARK, 6)
        # Front leg (lunge down 90 deg)
        draw_line(c, 165, 175, 140, 205, ORANGE, 6) # thigh
        draw_line(c, 140, 205, 145, 250, ORANGE, 6) # calf down to ground
        # Rear leg (on bench)
        draw_line(c, 165, 175, 230, 215, DARK, 6) # knee down
        draw_line(c, 230, 215, 280, 180, DARK, 6) # foot on bench
        # Target muscle indicator (accent dot on glute/quad)
        draw_circle(c, 155, 190, 8, ACCENT)
        
    elif filename == "calf_raises":
        # Step box on floor
        draw_rect(c, 160, 210, 240, 250, BENCH)
        # Head
        draw_circle(c, 200, 80, 16, DARK)
        # Torso
        draw_line(c, 200, 96, 200, 160, DARK, 6)
        # Stance leg
        draw_line(c, 200, 160, 200, 205, DARK, 6)
        # Foot raised high on ball of foot
        draw_line(c, 200, 205, 200, 220, ORANGE, 6)
        # Arrow up indicator
        draw_line(c, 240, 180, 240, 140, ACCENT, 4)
        draw_line(c, 233, 150, 240, 140, ACCENT, 4)
        draw_line(c, 247, 150, 240, 140, ACCENT, 4)
        draw_circle(c, 200, 180, 8, ACCENT)
        
    elif filename == "glute_bridge":
        # Torso on ground
        draw_circle(c, 100, 230, 14, DARK) # head on mat
        # Spine arched up
        draw_line(c, 114, 230, 185, 185, DARK, 6) # torso up
        draw_line(c, 185, 185, 250, 185, ORANGE, 7) # hips squeezed high
        draw_line(c, 250, 185, 280, 250, DARK, 6) # knees to feet
        # Target glute spark
        draw_circle(c, 205, 185, 9, ACCENT)
        
    elif filename == "side_plank":
        # Elbow on ground
        draw_line(c, 130, 250, 140, 210, DARK, 6) # arm
        # Head
        draw_circle(c, 120, 180, 14, DARK)
        # Body straight diagonal
        draw_line(c, 140, 210, 280, 250, DARK, 6)
        # Top leg abducted up
        draw_line(c, 210, 225, 275, 180, ORANGE, 6)
        draw_circle(c, 205, 220, 9, ACCENT)
        
    elif filename == "plank_taps":
        # Arms in push-up
        draw_line(c, 150, 250, 150, 195, DARK, 6) # left arm
        # Tap hand to shoulder
        draw_line(c, 150, 195, 120, 220, ORANGE, 6)
        # Head
        draw_circle(c, 125, 175, 14, DARK)
        # Body horizontal
        draw_line(c, 150, 195, 300, 250, DARK, 6)
        draw_circle(c, 210, 215, 9, ACCENT)
        
    elif filename == "bird_dog":
        # Hands & knees merangkak
        draw_circle(c, 170, 160, 14, DARK)
        # Back flat horizontal
        draw_line(c, 180, 180, 250, 180, DARK, 6)
        # Front arm extended straight
        draw_line(c, 180, 180, 100, 180, ORANGE, 6)
        # Back leg extended straight
        draw_line(c, 250, 180, 330, 180, ORANGE, 6)
        # Support arm and knee
        draw_line(c, 180, 180, 180, 250, DARK, 6)
        draw_line(c, 250, 180, 250, 250, DARK, 6)
        draw_circle(c, 215, 180, 8, ACCENT)
        
    elif filename == "single_leg_rdl":
        # Standing on one leg, body tilted
        draw_circle(c, 140, 140, 14, DARK)
        # Spine & rear leg horizontal line
        draw_line(c, 145, 150, 230, 180, DARK, 6) # torso
        draw_line(c, 230, 180, 330, 170, ORANGE, 6) # rear leg straight
        # Stance leg
        draw_line(c, 230, 180, 230, 250, DARK, 6)
        draw_circle(c, 230, 205, 9, ACCENT)
        
    elif filename == "wall_sit":
        # Wall on right
        draw_rect(c, 280, 60, 290, 250, BENCH)
        # Head against wall
        draw_circle(c, 260, 100, 15, DARK)
        # Back against wall
        draw_line(c, 275, 115, 275, 190, DARK, 6)
        # Thigh 90 deg forward
        draw_line(c, 275, 190, 210, 190, ORANGE, 7)
        # Shin 90 deg down to floor
        draw_line(c, 210, 190, 210, 250, DARK, 6)
        draw_circle(c, 240, 190, 9, ACCENT)

    out_path = f"assets/images/exercises/{filename}.png"
    with open(out_path, "wb") as f:
        f.write(canvas_to_png(c))

print("All 8 strength training illustration PNGs generated successfully in assets/images/exercises/")
