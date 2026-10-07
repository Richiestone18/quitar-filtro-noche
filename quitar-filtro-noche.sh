#!/bin/bash
# quitar-filtro-noche.sh
# Quita el filtro de temperatura de color nocturno del indicador
# "Display" de Ayatana (ayatana-indicator-display), el que cambia
# los tonos de la pantalla segun la hora del dia.
#
# Uso:
#   ./quitar-filtro-noche.sh          -> apaga el filtro (Manual, 6500K)
#   ./quitar-filtro-noche.sh --rev    -> lo regresa como estaba (adaptativo)
#
# Funciona en cualquier Ubuntu/MATE con ese indicador instalado.
# Ejecutar como usuario normal (NO con sudo), con sesion grafica abierta.

set -u

SCHEMA="org.ayatana.indicator.display"
KEY_TEMP="color-temp"
KEY_PERFIL="color-temp-profile"

salir() { echo; echo "Listo. $1"; exit 0; }
error() { echo "ERROR: $1" >&2; exit 1; }

# --- 0. Que corra en sesion grafica (dconf/gsettings necesitan la sesion) ---
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  error "Este script se ejecuta con la grafica abierta, no desde una terminal remota/consola."
fi

# --- 1. Herramientas necesarias ---
if ! command -v gsettings >/dev/null 2>&1; then
  error "No existe 'gsettings'. Instalar con: sudo apt install gsettings-desktop-schemas"
fi

# --- 2. Que el indicador este instalado ---
if ! gsettings list-schemas 2>/dev/null | grep -qx "$SCHEMA" \
   && ! gsettings list-relocatable-schemas 2>/dev/null | grep -qx "$SCHEMA"; then
  error "Esta computadora no tiene el indicador ayatana-indicator-display (esquema $SCHEMA). No hace falta nada."
fi

# --- 3. Accion ---
if [ "${1:-}" = "--rev" ]; then
  # Regresar al modo original: adaptativo (calido de noche segun la hora)
  gsettings set "$SCHEMA" "$KEY_TEMP" "uint16 4210"
  gsettings set "$SCHEMA" $KEY_PERFIL "uint16 2"
  ACCION="filtro nocturno RESTAURADO (adaptativo, 4210K)"
else
  # Modo Manual + 6500K = sin filtro, colores normales todo el tiempo
  gsettings set "$SCHEMA" "$KEY_PERFIL" "uint16 0"
  gsettings set "$SCHEMA" "$KEY_TEMP" "uint16 6500"
  ACCION="filtro nocturno APAGADO (Manual, 6500K)"
fi

# --- 4. Esperar a que el servicio lo aplique (reacciona en 2-5 s) ---
sleep 6

# --- 5. Verificar ---
PERFIL=$(gsettings get "$SCHEMA" $KEY_PERFIL)
TEMP=$(gsettings get "$SCHEMA" "$KEY_TEMP")

GAMMA=""
if command -v xrandr >/dev/null 2>&1; then
  GAMMA=$(xrandr --verbose 2>/dev/null | grep -m1 -i 'gamma' | tr -s ' ')
fi

echo "Accion : $ACCION"
echo "Perfil : $PERFIL  (0 = Manual, 2 = Adaptativo)"
echo "Temp   : $TEMP K"
[ -n "$GAMMA" ] && echo "Gamma  :$GAMMA"

# Comprobacion final
if [ "${1:-}" != "--rev" ]; then
  if [ "$PERFIL" = "uint16 0" ] && [ "$TEMP" = "uint16 6500" ]; then
    salir "La pantalla ya no cambia de tono por la hora."
  else
    error "Los valores no quedaron guardados. Reintentar."
  fi
else
  salir "Modo nocturno adaptativo restaurado."
fi
