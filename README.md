# quitar-filtro-noche

Quita el **filtro de temperatura de color nocturno** de Ubuntu/MATE (indicador
"Ayatana Display"), el que cambia los tonos de la pantalla de anaranjados
según la hora del día.

## Instalación directa (wget)

```bash
wget https://raw.githubusercontent.com/Richiestone18/quitar-filtro-noche/main/quitar-filtro-noche.sh
chmod +x quitar-filtro-noche.sh
./quitar-filtro-noche.sh
```

Ejecútalo **como usuario normal y con el escritorio abierto** (no con sudo,
no desde consola de texto).

## Qué hace

Pone el indicador en modo **Manual / 6500 K** (colores normales todo el
tiempo) y verifica el gamma real de la pantalla. Si el indicador no está
instalado en la máquina, lo detecta y sale sin cambiar nada.

Salida esperada:

```
Accion : filtro nocturno APAGADO (Manual, 6500K)
Perfil : uint16 0  (0 = Manual, 2 = Adaptativo)
Temp   : uint16 6500 K
Gamma  :       Gamma: 1.0:1.0:1.0

Listo. La pantalla ya no cambia de tono por la hora.
```

## Restaurar el modo nocturno original

```bash
./quitar-filtro-noche.sh --rev
```

Regresa al modo adaptativo (4210 K), que calienta la pantalla de noche
según la hora.

## Requisitos

- Ubuntu/MATE (o similar) con `ayatana-indicator-display`
- Sesión gráfica abierta (`gsettings`, `xrandr`)
