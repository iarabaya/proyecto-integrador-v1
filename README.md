# Gatito Code (proyecto-integrador-v1)

Juego didactico hecho en Godot para introducir logica de programacion por secuencias.
El jugador arma una cola de comandos (arriba, abajo, izquierda, derecha, salto)
y luego ejecuta el programa para recolectar todos los pickups del nivel.

## Resumen rapido

- Engine: Godot 4.6 (GL Compatibility)
- Resolucion base: 480x270 (escalada a 960x540)
- Genero: puzzle por programacion de movimientos
- Progresion: 3 niveles (`gym`, `level2`, `level3`) con desbloqueo secuencial
- Guardado: archivo JSON en `user://save.json`

## Como se juega

1. En cada nivel agregas comandos a una cola desde la interfaz.
2. Presionas Ejecutar para correr la secuencia completa.
3. El personaje se mueve en grilla de 16x16 y recoge objetos al pisarlos.
4. Si recoges todo, el nivel se marca como completado y se desbloquea el siguiente.

Notas de mecanica:

- `jump`: salto en el lugar (no cambia de tile).
- `jump_<direccion>`: salto de 2 tiles en linea recta.
- El salto puede pasar por encima de un obstaculo intermedio, pero el tile final debe ser valido.
- Agua y muros se consideran bloques solidos para colision.

## Flujo de escenas

- Escena principal configurada en el proyecto: `scenes/main_menu/main_menu.tscn`
- Desde menu principal:
	- Jugar -> continuar partida (si existe save) o iniciar desde `gym`
	- Niveles -> selector de niveles
- Escena de juego: `scenes/game_level/game_level.tscn`
	- Carga mapa desde JSON
	- Instancia jugador
	- Instancia pickups/decoracion
	- Ejecuta cola de comandos
	- Muestra overlay de victoria

## Arquitectura (scripts clave)

- `scripts/level_loader.gd`
	- Lee `levels/<key>.json`
	- Llena capas de tilemap (piso y muros)
	- Construye matriz `solid[][]`
- `scripts/gid_mapper.gd`
	- Convierte GID del JSON a `source_id + coords` del TileSet de Godot
- `scripts/player_model.gd`
	- Logica pura de movimiento y colision
	- Sin nodos ni render
- `scenes/player/player.gd`
	- Capa visual del jugador (animaciones y tweens)
- `scripts/program_executor.gd`
	- Ejecuta secuencia de comandos paso a paso
	- Notifica paso activo para highlight en UI
- `scripts/pickup_manager.gd`
	- Spawnea objetos del nivel
	- Detecta recoleccion y efectos visuales
- `scripts/save_system.gd` (autoload)
	- Progreso, desbloqueos, continuar partida y reset
- `scenes/command_ui/command_ui.gd`
	- Cola de comandos, borrar, ejecutar, reiniciar, highlight

## Estructura de niveles JSON

Cada nivel en `levels/*.json` define:

- `cols`, `rows`, `tile`
- `layers.floor`: arreglo lineal de GIDs de piso
- `layers.walls`: arreglo lineal de GIDs de colision/objetos de muro
- `spawn`: tile inicial del jugador (`tx`, `ty`)
- `objects`: lista de objetos con:
	- `tx`, `ty`
	- `key` (hoja de sprites)
	- `frame`
	- `type` (`pickup` o `deco`)

## Ejecutar el proyecto

1. Abrir la carpeta del repo en Godot 4.6.
2. Cargar `project.godot`.
3. Ejecutar la escena principal (`F5`).

## Estado actual

- Hay placeholders de `Settings` y `Credits` en menu principal.
- Existe escena/script de boot, pero la escena principal activa en `project.godot`
	es el menu principal.

## Idea de siguientes mejoras

- Agregar tutorial inicial con validaciones de comandos.
- Soporte para funciones reutilizables (slot `func1`) en UI.
- Efectos de clima usando el bloque `weather` ya presente en JSON.
