#!/bin/bash

MERAH='\033[0;31m'; MERAH_TERANG='\033[1;31m'; HIJAU='\033[0;32m'; HIJAU_TERANG='\033[1;32m'
KUNING='\033[1;33m'; BIRU='\033[0;34m'; BIRU_TERANG='\033[1;34m'; CYAN='\033[0;36m'
CYAN_TERANG='\033[1;36m'; PUTIH='\033[1;37m'; ABU='\033[1;30m'; EMAS='\033[1;33m'
NC='\033[0m'; BOLD='\033[1m'

SAVE_FILE="$(dirname "$0")/reme_save.dat"

saldo=2000
total_spin=0
total_menang=0
total_kalah=0
inv_luck=0
inv_jackpot=0
inv_double=0
aktif_luck=0
aktif_jackpot=0
aktif_double=0

auto_win=(19 0 28)
auto_lose=(29 1)

simpan() {
    cat > "$SAVE_FILE" << SAVEDATA
saldo=$saldo
total_spin=$total_spin
total_menang=$total_menang
total_kalah=$total_kalah
inv_luck=$inv_luck
inv_jackpot=$inv_jackpot
inv_double=$inv_double
aktif_luck=$aktif_luck
aktif_jackpot=$aktif_jackpot
aktif_double=$aktif_double
SAVEDATA
}

muat() {
    if [ -f "$SAVE_FILE" ]; then
        source "$SAVE_FILE"
    fi
}
muat

jumlah_angka() {
    local n=$1
    while [ $n -ge 10 ]; do
        local sum=0
        while [ $n -gt 0 ]; do
            sum=$((sum + n % 10))
            n=$((n / 10))
        done
        n=$sum
    done
    echo $n
}

cek_status() {
    local angka=$1
    for w in "${auto_win[@]}"; do
        [ $angka -eq $w ] && echo "win" && return
    done
    for l in "${auto_lose[@]}"; do
        [ $angka -eq $l ] && echo "lose" && return
    done
    echo "normal"
}

garis_emas()   { echo -e "      ${EMAS}══════════════════════════════════════${NC}"; }
garis_putih()  { echo -e "      ${PUTIH}──────────────────────────────────────${NC}"; }
garis_merah()  { echo -e "      ${MERAH}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
garis_hijau()  { echo -e "      ${HIJAU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
garis_kuning() { echo -e "      ${KUNING}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

tombol_kembali() {
    echo ""
    garis_putih
    echo -e "      ${ABU}◄ KEMBALI${NC}   ${ABU}[tekan Enter]${NC}"
    garis_putih
    read
}

header_vegas() {
    clear
    echo ""
    echo -e "      ${EMAS}╔══════════════════════════════════════╗${NC}"
    echo -e "      ${EMAS}║   ${BOLD}${PUTIH}✦  R E M E   C A S I N O  ✦${NC}      ${EMAS}║${NC}"
    echo -e "      ${EMAS}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "      ${CYAN_TERANG}⋆   L A S   V E G A S   S T R I P   ⋆${NC}"
    echo -e "      ${ABU}──────────────────────────────────────${NC}"
    echo -e "      ${KUNING}♠ ♥ ♣ ♦     W E L C O M E     ♠ ♥ ♣ ♦${NC}"
    echo ""
}

chip_display() {
    echo -e "      ${EMAS}╔══════════════════════════════════════╗${NC}"
    echo -e "      ${EMAS}║  ${CYAN_TERANG}💎  C H I P   B A L A N C E  💎   ${EMAS}║${NC}"
    echo -e "      ${EMAS}║  ${PUTIH}💰  Rp ${saldo}${NC}"
    echo -e "      ${EMAS}║  ${ABU}🎰 SPIN:${total_spin}  ✅ WIN:${total_menang}  ❌ LOSE:${total_kalah}${NC}"
    echo -e "      ${EMAS}╚══════════════════════════════════════╝${NC}"
    echo ""
}

potion_status() {
    local ada=0
    [ $aktif_luck -gt 0 ]    && ada=1
    [ $aktif_jackpot -gt 0 ] && ada=1
    [ $aktif_double -gt 0 ]  && ada=1
    if [ $ada -eq 1 ]; then
        echo -e "      ${CYAN_TERANG}✨ Potion Aktif:${NC}"
        [ $aktif_luck -gt 0 ]    && echo -e "      ${HIJAU}  🍀 Luck Potion (sisa ${aktif_luck} spin)${NC}"
        [ $aktif_jackpot -gt 0 ] && echo -e "      ${EMAS}  💰 Jackpot Potion aktif${NC}"
        [ $aktif_double -gt 0 ]  && echo -e "      ${CYAN_TERANG}  ⚡ Double Reward (sisa ${aktif_double} spin)${NC}"
        echo ""
    fi
}

# ─── ANIMASI COIN FLIP ───────────────────────────────

animasi_coin() {
    local frames=(
"      ${EMAS}    ╭───────╮    ${NC}"
"      ${EMAS}   │  ╔═╗  │   ${NC}"
"      ${EMAS}   │  ║H║  │   ${NC}"
"      ${EMAS}   │  ╚═╝  │   ${NC}"
"      ${EMAS}    ╰───────╯    ${NC}"

"      ${PUTIH}      │││      ${NC}"
"      ${PUTIH}     ─────     ${NC}"
"      ${PUTIH}      │││      ${NC}"

"      ${EMAS}    ╭───────╮    ${NC}"
"      ${EMAS}   │  ╔═╗  │   ${NC}"
"      ${EMAS}   │  ║T║  │   ${NC}"
"      ${EMAS}   │  ╚═╝  │   ${NC}"
"      ${EMAS}    ╰───────╯    ${NC}"

"      ${PUTIH}      │││      ${NC}"
"      ${PUTIH}     ─────     ${NC}"
"      ${PUTIH}      │││      ${NC}"
    )

    local coin_H=(
"      ${EMAS}    ╭───────╮    ${NC}"
"      ${EMAS}   │  ╔═══╗ │   ${NC}"
"      ${EMAS}   │  ║ H ║ │   ${NC}"
"      ${EMAS}   │  ╚═══╝ │   ${NC}"
"      ${EMAS}    ╰───────╯    ${NC}"
    )

    local coin_T=(
"      ${CYAN_TERANG}    ╭───────╮    ${NC}"
"      ${CYAN_TERANG}   │  ╔═══╗ │   ${NC}"
"      ${CYAN_TERANG}   │  ║ T ║ │   ${NC}"
"      ${CYAN_TERANG}   │  ╚═══╝ │   ${NC}"
"      ${CYAN_TERANG}    ╰───────╯    ${NC}"
    )

    local coin_side=(
"      ${ABU}        │        ${NC}"
"      ${ABU}      ══╪══      ${NC}"
"      ${ABU}        │        ${NC}"
    )

    local coin_thin=(
"      ${PUTIH}       ╔╗       ${NC}"
"      ${PUTIH}       ╚╝       ${NC}"
    )

    # Fase 1: Lempar ke atas
    for i in {1..3}; do
        clear
        echo ""
        echo -e "      ${KUNING}🪙   L E M P A R . . .${NC}"
        echo ""
        for line in "${coin_H[@]}"; do echo -e "$line"; done
        sleep 0.15
        clear
        echo ""
        echo -e "      ${KUNING}🪙   L E M P A R . . .${NC}"
        echo ""
        for line in "${coin_side[@]}"; do echo -e "$line"; done
        sleep 0.1
        clear
        echo ""
        echo -e "      ${KUNING}🪙   L E M P A R . . .${NC}"
        echo ""
        for line in "${coin_thin[@]}"; do echo -e "$line"; done
        sleep 0.08
        clear
        echo ""
        echo -e "      ${KUNING}🪙   L E M P A R . . .${NC}"
        echo ""
        for line in "${coin_T[@]}"; do echo -e "$line"; done
        sleep 0.15
        clear
        echo ""
        echo -e "      ${KUNING}🪙   L E M P A R . . .${NC}"
        echo ""
        for line in "${coin_side[@]}"; do echo -e "$line"; done
        sleep 0.1
        clear
        echo ""
        echo -e "      ${KUNING}🪙   L E M P A R . . .${NC}"
        echo ""
        for line in "${coin_thin[@]}"; do echo -e "$line"; done
        sleep 0.08
    done

    # Fase 2: Melambat
    for i in {1..2}; do
        clear
        echo ""
        echo -e "      ${KUNING}🪙   M E N D A R A T . . .${NC}"
        echo ""
        for line in "${coin_H[@]}"; do echo -e "$line"; done
        sleep 0.25
        clear
        echo ""
        echo -e "      ${KUNING}🪙   M E N D A R A T . . .${NC}"
        echo ""
        for line in "${coin_T[@]}"; do echo -e "$line"; done
        sleep 0.25
    done
}

# ─── COIN FLIP GAME ──────────────────────────────────

coin_flip() {
    while true; do
        header_vegas
        chip_display
        garis_emas
        echo -e "      ${EMAS}🪙   C O I N   F L I P${NC}"
        garis_emas
        echo ""
        echo -e "      ${ABU}Pilih sisi koin:${NC}"
        echo ""
        echo -e "      ${EMAS}[1]${NC}  👑  HEADS"
        echo -e "      ${EMAS}[2]${NC}  🦅  TAILS"
        echo ""
        garis_putih
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo -e "      ${PUTIH}[0]  ◄ KEMBALI KE MENU${NC}"
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo ""
        echo -n "      ➤  "
        read pilih

        [ "$pilih" == "0" ] && return

        if [ "$pilih" != "1" ] && [ "$pilih" != "2" ]; then
            garis_merah
            echo -e "      ${MERAH_TERANG}❌  Pilihan tidak valid!${NC}"
            garis_merah
            sleep 1
            continue
        fi

        if [ "$pilih" == "1" ]; then
            pilihan="heads"
            pilihan_label="👑 HEADS"
        else
            pilihan="tails"
            pilihan_label="🦅 TAILS"
        fi

        clear
        echo ""
        garis_kuning
        echo -e "      ${PUTIH}Pilihan kamu: ${EMAS}${pilihan_label}${NC}"
        garis_kuning
        echo ""
        echo -e "      ${CYAN_TERANG}Masukkan taruhan:${NC}"
        echo ""
        echo -n "      ➤  Rp "
        read taruhan

        if ! [[ "$taruhan" =~ ^[0-9]+$ ]] || [ "$taruhan" -le 0 ]; then
            garis_merah
            echo -e "      ${MERAH_TERANG}❌  Taruhan harus angka positif!${NC}"
            garis_merah
            sleep 2
            continue
        fi

        if [ $taruhan -gt $saldo ]; then
            garis_merah
            echo -e "      ${MERAH_TERANG}❌  Saldo tidak cukup!${NC}"
            garis_merah
            sleep 2
            continue
        fi

        # Animasi coin
        animasi_coin

        # Hasil
        hasil=$((RANDOM % 2))
        if [ $hasil -eq 0 ]; then
            hasil_str="heads"
            hasil_label="👑 HEADS"
            hasil_color="${EMAS}"
        else
            hasil_str="tails"
            hasil_label="🦅 TAILS"
            hasil_color="${CYAN_TERANG}"
        fi

        clear
        echo ""
        echo -e "      ${KUNING}🪙   H A S I L   L E M P A R A N${NC}"
        echo ""
        if [ "$hasil_str" == "heads" ]; then
            echo -e "      ${EMAS}    ╭───────╮    ${NC}"
            echo -e "      ${EMAS}   │  ╔═══╗ │   ${NC}"
            echo -e "      ${EMAS}   │  ║ H ║ │   ${NC}"
            echo -e "      ${EMAS}   │  ╚═══╝ │   ${NC}"
            echo -e "      ${EMAS}    ╰───────╯    ${NC}"
        else
            echo -e "      ${CYAN_TERANG}    ╭───────╮    ${NC}"
            echo -e "      ${CYAN_TERANG}   │  ╔═══╗ │   ${NC}"
            echo -e "      ${CYAN_TERANG}   │  ║ T ║ │   ${NC}"
            echo -e "      ${CYAN_TERANG}   │  ╚═══╝ │   ${NC}"
            echo -e "      ${CYAN_TERANG}    ╰───────╯    ${NC}"
        fi
        echo ""
        echo -e "      ${PUTIH}Hasil  : ${hasil_color}${hasil_label}${NC}"
        echo -e "      ${PUTIH}Pilihan: ${EMAS}${pilihan_label}${NC}"
        echo ""

        total_spin=$((total_spin + 1))

        if [ "$pilihan" == "$hasil_str" ]; then
            reward=$taruhan
            saldo=$((saldo + reward))
            total_menang=$((total_menang + 1))
            garis_hijau
            echo -e "      ${HIJAU_TERANG}🎉   VICTORY!   +Rp $reward${NC}"
            echo -e "      ${HIJAU}💰   Saldo: Rp $saldo${NC}"
            garis_hijau
        else
            saldo=$((saldo - taruhan))
            total_kalah=$((total_kalah + 1))
            garis_merah
            echo -e "      ${MERAH_TERANG}💔   DEFEAT!   -Rp $taruhan${NC}"
            echo -e "      ${MERAH}💰   Saldo: Rp $saldo${NC}"
            garis_merah
        fi

        simpan
        echo ""

        if [ $saldo -le 0 ]; then
            garis_merah
            echo -e "      ${MERAH_TERANG}💸   GAME OVER - Saldo habis!${NC}"
            garis_merah
            echo ""
            echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
            echo -e "      ${PUTIH}   ◄ KEMBALI   [tekan Enter]${NC}"
            echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
            read
            return
        fi

        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo -e "      ${PUTIH}[Enter] Main lagi   [0] ◄ Kembali${NC}"
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo -n "      ➤  "
        read lagi
        [ "$lagi" == "0" ] && return
    done
}

# ─── SHOP ────────────────────────────────────────────

shop() {
    while true; do
        header_vegas
        chip_display
        garis_emas
        echo -e "      ${EMAS}🛒   P O T I O N   S H O P${NC}"
        garis_emas
        echo ""
        echo -e "      ${EMAS}[1]${NC}  🍀  Luck Potion"
        echo -e "           ${ABU}Win chance +2% selama 3 spin${NC}"
        echo -e "           ${KUNING}Harga: 1000 chip${NC}"
        echo ""
        echo -e "      ${EMAS}[2]${NC}  💰  Jackpot Potion"
        echo -e "           ${ABU}Bonus 10%-50% dari taruhan jika menang${NC}"
        echo -e "           ${KUNING}Harga: 1500 chip${NC}"
        echo ""
        echo -e "      ${EMAS}[3]${NC}  ⚡  Double Reward Potion"
        echo -e "           ${ABU}40% chance reward x2 selama 3 spin${NC}"
        echo -e "           ${KUNING}Harga: 2500 chip${NC}"
        echo ""
        garis_putih
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo -e "      ${PUTIH}[0]  ◄ KEMBALI KE MENU${NC}"
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo ""
        echo -n "      ➤  "
        read beli

        case $beli in
            0) return ;;
            1)
                if [ $saldo -ge 1000 ]; then
                    saldo=$((saldo - 1000))
                    inv_luck=$((inv_luck + 1))
                    simpan
                    garis_hijau
                    echo -e "      ${HIJAU_TERANG}✅  Luck Potion dibeli! Stok: ${inv_luck}x${NC}"
                    garis_hijau
                else
                    garis_merah
                    echo -e "      ${MERAH_TERANG}❌  Saldo tidak cukup!${NC}"
                    garis_merah
                fi
                sleep 1 ;;
            2)
                if [ $saldo -ge 1500 ]; then
                    saldo=$((saldo - 1500))
                    inv_jackpot=$((inv_jackpot + 1))
                    simpan
                    garis_hijau
                    echo -e "      ${HIJAU_TERANG}✅  Jackpot Potion dibeli! Stok: ${inv_jackpot}x${NC}"
                    garis_hijau
                else
                    garis_merah
                    echo -e "      ${MERAH_TERANG}❌  Saldo tidak cukup!${NC}"
                    garis_merah
                fi
                sleep 1 ;;
            3)
                if [ $saldo -ge 2500 ]; then
                    saldo=$((saldo - 2500))
                    inv_double=$((inv_double + 1))
                    simpan
                    garis_hijau
                    echo -e "      ${HIJAU_TERANG}✅  Double Reward Potion dibeli! Stok: ${inv_double}x${NC}"
                    garis_hijau
                else
                    garis_merah
                    echo -e "      ${MERAH_TERANG}❌  Saldo tidak cukup!${NC}"
                    garis_merah
                fi
                sleep 1 ;;
            *)
                echo -e "      ${MERAH_TERANG}❌  Tidak valid!${NC}"
                sleep 1 ;;
        esac
    done
}

# ─── INVENTORY ───────────────────────────────────────

inventory() {
    while true; do
        header_vegas
        chip_display
        garis_emas
        echo -e "      ${EMAS}🎒   I N V E N T O R Y${NC}"
        garis_emas
        echo ""
        echo -e "      ${PUTIH}Stok item:${NC}"
        echo -e "      🍀  Luck Potion       : ${HIJAU}${inv_luck}x${NC}"
        echo -e "      💰  Jackpot Potion    : ${EMAS}${inv_jackpot}x${NC}"
        echo -e "      ⚡  Double Reward     : ${CYAN_TERANG}${inv_double}x${NC}"
        echo ""
        garis_putih
        echo -e "      ${PUTIH}Status aktif:${NC}"
        if [ $aktif_luck -gt 0 ]; then
            echo -e "      🍀  ${HIJAU}Luck Potion AKTIF — sisa ${aktif_luck} spin${NC}"
        else
            echo -e "      🍀  ${ABU}Luck Potion — tidak aktif${NC}"
        fi
        if [ $aktif_jackpot -gt 0 ]; then
            echo -e "      💰  ${EMAS}Jackpot Potion AKTIF${NC}"
        else
            echo -e "      💰  ${ABU}Jackpot Potion — tidak aktif${NC}"
        fi
        if [ $aktif_double -gt 0 ]; then
            echo -e "      ⚡  ${CYAN_TERANG}Double Reward AKTIF — sisa ${aktif_double} spin${NC}"
        else
            echo -e "      ⚡  ${ABU}Double Reward — tidak aktif${NC}"
        fi
        echo ""
        garis_emas
        echo -e "      ${EMAS}[1]${NC}  🍀  Pakai Luck Potion"
        echo -e "      ${EMAS}[2]${NC}  💰  Pakai Jackpot Potion"
        echo -e "      ${EMAS}[3]${NC}  ⚡  Pakai Double Reward Potion"
        echo ""
        garis_putih
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo -e "      ${PUTIH}[0]  ◄ KEMBALI KE MENU${NC}"
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo ""
        echo -n "      ➤  "
        read pakai

        case $pakai in
            0) return ;;
            1)
                if [ $inv_luck -gt 0 ]; then
                    inv_luck=$((inv_luck - 1))
                    aktif_luck=3
                    simpan
                    echo -e "      ${HIJAU_TERANG}✅  Luck Potion aktif untuk 3 spin!${NC}"
                else
                    echo -e "      ${MERAH_TERANG}❌  Luck Potion habis!${NC}"
                fi
                sleep 1 ;;
            2)
                if [ $inv_jackpot -gt 0 ]; then
                    inv_jackpot=$((inv_jackpot - 1))
                    aktif_jackpot=1
                    simpan
                    echo -e "      ${HIJAU_TERANG}✅  Jackpot Potion aktif!${NC}"
                else
                    echo -e "      ${MERAH_TERANG}❌  Jackpot Potion habis!${NC}"
                fi
                sleep 1 ;;
            3)
                if [ $inv_double -gt 0 ]; then
                    inv_double=$((inv_double - 1))
                    aktif_double=3
                    simpan
                    echo -e "      ${HIJAU_TERANG}✅  Double Reward aktif untuk 3 spin!${NC}"
                else
                    echo -e "      ${MERAH_TERANG}❌  Double Reward Potion habis!${NC}"
                fi
                sleep 1 ;;
            *)
                echo -e "      ${MERAH_TERANG}❌  Tidak valid!${NC}"
                sleep 1 ;;
        esac
    done
}

# ─── ROULETTE ────────────────────────────────────────

main_game_reme() {
    while true; do
        clear
        echo ""
        echo -e "      ${MERAH_TERANG}██████╗ ███████╗███╗   ███╗███████╗${NC}"
        echo -e "      ${MERAH_TERANG}██╔══██╗██╔════╝████╗ ████║██╔════╝${NC}"
        echo -e "      ${MERAH_TERANG}██████╔╝█████╗  ██╔████╔██║█████╗  ${NC}"
        echo -e "      ${MERAH_TERANG}██╔══██╗██╔══╝  ██║╚██╔╝██║██╔══╝  ${NC}"
        echo -e "      ${MERAH_TERANG}██║  ██║███████╗██║ ╚═╝ ██║███████╗${NC}"
        echo -e "      ${MERAH_TERANG}╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝${NC}"
        echo ""
        chip_display
        potion_status
        garis_emas
        echo -e "      ${PUTIH}🎲   M A S U K K A N   T A R U H A N${NC}"
        garis_emas
        echo ""
        garis_putih
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo -e "      ${PUTIH}[0]  ◄ KEMBALI KE MENU${NC}"
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo ""
        echo -n "      ➤  Rp "
        read taruhan

        [ "$taruhan" == "0" ] && return

        if ! [[ "$taruhan" =~ ^[0-9]+$ ]] || [ "$taruhan" -le 0 ]; then
            garis_merah
            echo -e "      ${MERAH_TERANG}❌  Taruhan harus angka positif!${NC}"
            garis_merah
            sleep 2; continue
        fi

        if [ $taruhan -gt $saldo ]; then
            garis_merah
            echo -e "      ${MERAH_TERANG}❌  Saldo tidak cukup!${NC}"
            garis_merah
            sleep 2; continue
        fi

        echo ""
        garis_putih
        echo -e "      ${KUNING}🎰   S P I N N I N G . . .${NC}"
        garis_putih
        for i in $(seq 1 12); do
            angka_acak=$((RANDOM % 37))
            printf -v tampil "%02d" $angka_acak
            echo -ne "\r      ${MERAH}● ${tampil} ●${NC}      "
            sleep 0.2
        done
        echo -e "\n"

        total_spin=$((total_spin + 1))
        player_angka=$((RANDOM % 37))
        bot_angka=$((RANDOM % 37))
        printf -v player_tampil "%02d" $player_angka
        printf -v bot_tampil "%02d" $bot_angka
        player_jumlah=$(jumlah_angka $player_angka)
        bot_jumlah=$(jumlah_angka $bot_angka)

        echo ""
        garis_putih
        echo -e "      ${EMAS}🎯   H A S I L${NC}"
        garis_putih
        echo ""
        echo -e "      ${PUTIH}Anda  :  ${BIRU_TERANG}${BOLD}$player_tampil${NC}  ➜  ${BIRU}Jumlah: $player_jumlah${NC}"
        echo -e "      ${PUTIH}Bot   :  ${MERAH_TERANG}${BOLD}$bot_tampil${NC}  ➜  ${MERAH}Jumlah: $bot_jumlah${NC}"
        echo ""

        player_status=$(cek_status $player_angka)
        bot_status=$(cek_status $bot_angka)

        if   [ "$player_status" == "win"  ]; then ps_label="${HIJAU_TERANG}AUTO WIN${NC}"
        elif [ "$player_status" == "lose" ]; then ps_label="${MERAH_TERANG}AUTO LOSE${NC}"
        else ps_label="${KUNING}NORMAL${NC}"; fi
        if   [ "$bot_status" == "win"  ]; then bs_label="${HIJAU_TERANG}AUTO WIN${NC}"
        elif [ "$bot_status" == "lose" ]; then bs_label="${MERAH_TERANG}AUTO LOSE${NC}"
        else bs_label="${KUNING}NORMAL${NC}"; fi

        echo -e "      ${PUTIH}Status Anda  :  $(echo -e $ps_label)"
        echo -e "      ${PUTIH}Status Bot   :  $(echo -e $bs_label)"
        echo ""

        if   [ "$player_status" == "win"  ] && [ "$bot_status"    != "win"  ]; then hasil="win";  alasan="AUTO WIN"
        elif [ "$bot_status"    == "win"  ] && [ "$player_status" != "win"  ]; then hasil="lose"; alasan="BOT AUTO WIN"
        elif [ "$player_status" == "lose" ] && [ "$bot_status"    != "lose" ]; then hasil="lose"; alasan="AUTO LOSE"
        elif [ "$bot_status"    == "lose" ] && [ "$player_status" != "lose" ]; then hasil="win";  alasan="BOT AUTO LOSE"
        elif [ $player_jumlah -gt $bot_jumlah ]; then hasil="win";  alasan="JUMLAH LEBIH BESAR"
        elif [ $player_jumlah -lt $bot_jumlah ]; then
            roll=$((RANDOM % 100))
            threshold=40
            [ $aktif_luck -gt 0 ] && threshold=42
            if [ $roll -lt $threshold ]; then
                hasil="win"; alasan="JUMLAH LEBIH KECIL (LUCK!)"
            else
                hasil="lose"; alasan="JUMLAH LEBIH KECIL"
            fi
        else
            hasil="win"; alasan="JUMLAH SAMA"
        fi

        [ $aktif_luck -gt 0 ] && aktif_luck=$((aktif_luck - 1))

        echo -ne "      ${ABU}Menentukan pemenang"
        for i in {1..3}; do echo -n "."; sleep 0.5; done
        echo -e "${NC}\n"

        if [ "$hasil" == "win" ]; then
            reward=$taruhan
            bonus_info=""
            double_info=""

            if [ $aktif_jackpot -gt 0 ]; then
                pct=$(( (RANDOM % 41) + 10 ))
                bonus=$((taruhan * pct / 100))
                reward=$((reward + bonus))
                aktif_jackpot=0
                bonus_info="${EMAS}  💰 Jackpot Potion: +Rp ${bonus} (${pct}% bonus)!${NC}"
            fi

            if [ $aktif_double -gt 0 ]; then
                roll_double=$((RANDOM % 100))
                if [ $roll_double -lt 40 ]; then
                    reward=$((reward * 2))
                    double_info="${CYAN_TERANG}  ⚡ Double Reward TRIGGERED! reward x2!${NC}"
                else
                    double_info="${ABU}  ⚡ Double Reward: tidak triggered${NC}"
                fi
                aktif_double=$((aktif_double - 1))
            fi

            saldo=$((saldo + reward))
            total_menang=$((total_menang + 1))

            [ -n "$bonus_info" ]  && echo -e "      $bonus_info"
            [ -n "$double_info" ] && echo -e "      $double_info"

            garis_hijau
            echo -e "      ${HIJAU_TERANG}🎉   VICTORY!   +Rp $reward${NC}"
            echo -e "      ${HIJAU}💰   Saldo: Rp $saldo${NC}"
            garis_hijau
        else
            saldo=$((saldo - taruhan))
            total_kalah=$((total_kalah + 1))
            [ $aktif_double -gt 0 ] && aktif_double=$((aktif_double - 1))
            garis_merah
            echo -e "      ${MERAH_TERANG}💔   DEFEAT!   -Rp $taruhan${NC}"
            echo -e "      ${MERAH}💰   Saldo: Rp $saldo${NC}"
            garis_merah
        fi

        echo -e "      ${PUTIH}📋   Alasan: $alasan${NC}"
        simpan

        echo ""
        if [ $saldo -le 0 ]; then
            garis_merah
            echo -e "      ${MERAH_TERANG}💸   GAME OVER - Saldo habis!${NC}"
            garis_merah
            echo ""
            echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
            echo -e "      ${PUTIH}   ◄ KEMBALI   [tekan Enter]${NC}"
            echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
            read
            return
        fi

        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo -e "      ${PUTIH}[Enter] Main lagi   [0] ◄ Kembali${NC}"
        echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
        echo -n "      ➤  "
        read lagi
        [ "$lagi" == "0" ] && return
    done
}

# ─── DEPOSIT ─────────────────────────────────────────

tambah_saldo() {
    header_vegas
    chip_display
    garis_kuning
    echo -e "      ${PUTIH}💳   T A M B A H   S A L D O${NC}"
    garis_kuning
    echo ""
    echo -e "      ${CYAN_TERANG}Jumlah deposit:${NC}"
    echo -n "      ➤  Rp "
    read tambah
    if [[ "$tambah" =~ ^[0-9]+$ ]] && [ $tambah -gt 0 ]; then
        saldo=$((saldo + tambah))
        simpan
        garis_hijau
        echo -e "      ${HIJAU_TERANG}✅  Berhasil! Saldo: Rp $saldo${NC}"
        garis_hijau
    else
        garis_merah
        echo -e "      ${MERAH_TERANG}❌  Nomor tidak valid!${NC}"
        garis_merah
    fi
    echo ""
    echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
    echo -e "      ${PUTIH}   ◄ KEMBALI   [tekan Enter]${NC}"
    echo -e "      ${ABU}◄──────────────────────────────────────${NC}"
    read
}

# ─── MAIN MENU ───────────────────────────────────────

while true; do
    header_vegas
    chip_display
    garis_emas
    echo -e "      ${CYAN_TERANG}🎰   M E N U   U T A M A${NC}"
    garis_emas
    echo ""
    echo -e "      ${EMAS}[1]${NC}  🎲  Play Roulette (REME)"
    echo -e "      ${EMAS}[2]${NC}  🪙  Coin Flip"
    echo -e "      ${EMAS}[3]${NC}  🛒  Shop"
    echo -e "      ${EMAS}[4]${NC}  🎒  Inventory"
    echo -e "      ${EMAS}[5]${NC}  💳  Deposit"
    echo -e "      ${EMAS}[6]${NC}  🚪  Exit"
    echo ""
    garis_emas
    echo -e "      ${KUNING}♠ ♥ ♣ ♦   G O O D   L U C K   ♠ ♥ ♣ ♦${NC}"
    garis_kuning
    echo -n "      ➤  "
    read pilihan

    case $pilihan in
        1) main_game_reme ;;
        2) coin_flip ;;
        3) shop ;;
        4) inventory ;;
        5) tambah_saldo ;;
        6)
            header_vegas
            garis_emas
            echo -e "      ${EMAS}👋   T E R I M A   K A S I H !${NC}"
            garis_emas
            echo -e "      ${PUTIH}💰  Saldo akhir   : Rp $saldo${NC}"
            echo -e "      ${PUTIH}🎰  Total spin    : $total_spin${NC}"
            echo -e "      ${PUTIH}✅  Total menang  : $total_menang${NC}"
            echo -e "      ${PUTIH}❌  Total kalah   : $total_kalah${NC}"
            garis_emas
            echo -e "      ${KUNING}🌟   Sampai jumpa di Las Vegas!   🌟${NC}"
            echo ""
            simpan
            exit 0 ;;
        *)
            garis_merah
            echo -e "      ${MERAH_TERANG}❌  Pilihan tidak valid!${NC}"
            garis_merah
            sleep 1 ;;
    esac
done
