# NAVE MORPHIS 3D
## ULTIMATE SPACE COMBAT EXPERIENCE

Un espectacular juego de combate espacial 3D con gráficos avanzados, IA inteligente y batallas épicas contra mothership destructible. Construido con SpriteKit y optimizado para iPhone.

## 🚀 INICIO SÚPER RÁPIDO

```bash
git clone git@github.com:tagaa8/nave_morphis.git
cd nave_morphis
open NaveMorphis.xcodeproj
```

**¡LISTO PARA EL COMBATE!** Presiona ▶️ en Xcode y prepárate para la batalla espacial más intensa.

## ✨ NUEVO EN v3.0 - ENHANCED EDITION

### 🌟 CARACTERÍSTICAS REVOLUCIONARIAS 3D
- **✦ Starfield Multi-Capa**: Campo de estrellas dinámico con 5 capas de profundidad y efecto parallax
- **✦ IA Enemiga Inteligente**: 5 tipos de enemigos con comportamientos únicos (Aggressive, Hunter, Sniper, Berserker, Guardian)
- **✦ Mothership Destructible**: Boss épico con módulos destructibles y múltiples fases de combate
- **✦ Efectos de Partículas Avanzados**: Explosiones volumétricas, rastros de propulsión y efectos de brillo
- **✦ Audio Espacial**: Sistema de sonido posicional 3D con AVAudioEngine
- **✦ Física Realista**: Colisiones precisas con efectos de inercia y momentum
- **✦ Power-ups Inteligentes**: 4 tipos con efectos visuales únicos (Vida Extra, Fuego Rápido, Escudo, Disparo Triple)

### 🎮 GAMEPLAY CORE MEJORADO
- **Controles Twin-Stick Fluidos**: Movimiento analógico suave con efectos de inclinación de nave
- **Auto-Fire Avanzado**: Sistema de disparo continuo con diferentes tipos de láser
- **Sistema de Oleadas Dinámicas**: Dificultad escalable con spawning inteligente de enemigos
- **Combo System**: Multiplicadores de puntuación por eliminaciones consecutivas
- **Mothership Boss Battles**: Batallas épicas cada 5 oleadas con fases múltiples

### 🎨 EFECTOS VISUALES 3D ESPECTACULARES
- **Starfield Multi-Dimensional**: 1000+ estrellas distribuidas en 5 capas con efecto parallax
- **Nebulosas Dinámicas**: 3 capas de nebulosas con colores cambiantes y movimiento orgánico
- **Naves con Efectos Avanzados**: Glow dinámico, rastros de propulsión y efectos de respiración
- **Explosiones Volumétricas**: Sistema de partículas multicapa con ondas de choque
- **Power-ups Flotantes**: Rotación 3D, auras de partículas y efectos de pulsación
- **Láseres con Rastro**: Efectos de trail dinámicos y colores diferenciados por tipo
- **Debris Espacial**: Objetos flotantes para mayor inmersión y profundidad visual

### 🤖 IA ENEMIGA DE NUEVA GENERACIÓN
- **🔥 AGGRESSIVE**: Ataque directo y feroz hacia el jugador
- **🎯 HUNTER**: Movimiento circular de cacería con targeting avanzado  
- **📡 SNIPER**: Mantiene distancia óptima con fuego de precisión
- **⚡ BERSERKER**: Movimiento errático y impredecible a alta velocidad
- **🛡️ GUARDIAN**: Patrulla defensiva con resistencia superior
- **Spawning Inteligente**: Aparición desde bordes con formaciones tácticas
- **Combat AI**: Sistema de disparo predictivo y evasión de proyectiles

### Sistema de Progresión
- **Oleadas incrementales**: Cada 1000 puntos = nueva oleada
- **Dificultad escalable**: Los enemigos son más frecuentes en oleadas superiores
- **Game Over**: Pierdes cuando se te acaban las vidas
- **Rejugabilidad**: Botones de "Play Again" y "Main Menu" al terminar

## 📱 Requisitos del Sistema

- **iOS**: 17.0 o superior
- **Dispositivos**: iPhone 12 o más reciente (recomendado)
- **Orientación**: Solo landscape (horizontal)
- **Xcode**: 15.0+ para desarrollo

## 🛠️ Instalación y Configuración

### ¡Súper Simple! Solo Clona y Abre

```bash
git clone git@github.com:tagaa8/nave_morphis.git
cd nave_morphis
open NaveMorphis.xcodeproj
```

¡Eso es todo! El proyecto está listo para compilar y ejecutar directamente en Xcode.

### Requisitos Previos
- **Xcode**: 15.0 o superior
- **iOS**: 17.0 o superior (iPhone 12+ recomendado)
- **macOS**: Con Xcode instalado

### Si Tienes Problemas
1. Asegúrate de tener Xcode 15+ instalado
2. Verifica que tu Mac puede ejecutar iOS Simulator
3. Si el proyecto no abre, reinstala Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

## 🎮 Controles y Gameplay

### Controles Táctiles
- **Lado izquierdo de la pantalla**: Movimiento
  - Arrastra el dedo para mover tu nave
  - La nave se mueve proporcionalmente a tu movimiento del dedo
  
- **Lado derecho de la pantalla**: Disparo
  - **Toque simple**: Disparo único
  - **Mantener presionado**: Auto-fire continuo (recomendado)

### Elementos de Juego
- **Nave Jugador** (triángulo cyan): Tu nave con efecto de brillo
- **Enemigos** (triángulos rojos): Vienen desde arriba persiguiéndote
- **Láseres verdes**: Tus proyectiles con efecto de brillo
- **Power-ups** (cuadrados magentas): Rotan y flotan, te dan +1 vida

### HUD (Interfaz)
- **Score**: Puntuación actual (esquina superior izquierda)
- **Wave**: Oleada actual (centro superior)
- **Lives**: Vidas restantes (esquina superior derecha)
- **Instrucciones**: "Left: Move | Right: Fire" (parte inferior)

## 🏗️ Arquitectura del Código

```
NaveMorphis/
├── NaveMorphis/
│   ├── AppDelegate.swift          # Entrada principal de la app
│   ├── GameViewController.swift   # Controlador principal, maneja orientación
│   ├── MainMenuScene.swift        # Menú principal con estrellas animadas
│   ├── GameScene.swift            # Lógica principal del juego
│   ├── GameOverScene.swift        # Pantalla final con high score
│   ├── Assets.xcassets/           # Sprites y recursos gráficos
│   ├── Base.lproj/                # Storyboards de la interfaz
│   └── Info.plist                 # Configuración de la app
└── NaveMorphis.xcodeproj/         # Archivo de proyecto Xcode
```

### Clases Principales

#### MainMenuScene
- Fondo estrellado con 100 estrellas parpadeantes
- Título "NAVE MORPHIS" con efectos de color
- Botón "TAP TO PLAY" con animación de pulso
- Transición fade al GameScene

#### GameScene  
- **setupBackground()**: Campo de 200 estrellas + nebulosa móvil
- **setupPlayer()**: Crea nave triangular con física y glow
- **createEnemy()**: Spawn enemigos con targeting inteligente  
- **fireLaser()**: Sistema de disparo con efectos visuales
- **didBegin()**: Maneja todas las colisiones del juego
- **handleTouches()**: Controles twin-stick divididos por mitad de pantalla

#### GameOverScene
- Guarda high score en UserDefaults
- Efecto de celebración si es nuevo récord
- Opciones de "Play Again" y "Main Menu"
- Fondo con estrellas y explosiones animadas

## 🔧 Personalización y Desarrollo

### Valores Configurables (en GameScene.swift)

```swift
// Gameplay
private var lastEnemySpawn: TimeInterval = 0    // Control de spawn
private var lastAutoFire: TimeInterval = 0      // Cadencia de disparo

// En update()
if currentTime - lastEnemySpawn > 2.0 && enemies.count < 5 {
    // Cambiar 2.0 para spawn más/menos frecuente
    // Cambiar 5 para más/menos enemigos simultáneos
}

if rightThumbstick != CGPoint.zero && currentTime - lastAutoFire > 0.2 {
    // Cambiar 0.2 para disparo más/menos rápido
}
```

### Añadir Nuevas Características

1. **Nuevos tipos de enemigos**:
   - Modificar `createEnemy()` para diferentes colores/comportamientos
   - Ajustar valores de puntuación y movimiento

2. **Power-ups adicionales**:
   - Extender lógica en `didBegin()` colisión player-powerup
   - Añadir diferentes efectos (velocidad, disparo múltiple, etc.)

3. **Efectos visuales**:
   - Modificar `createExplosion()` para diferentes tipos
   - Añadir más partículas en `setupBackground()`

## 🐛 Resolución de Problemas

### Errores Comunes

**"SKView implements focusItemsInRect"**
- ✅ **Ignorar**: Warning normal de SpriteKit, no afecta funcionalidad

**"fopen failed for data file"**  
- ✅ **Ignorar**: Sistema creando archivos de caché automáticamente

**"Failed to send CA Event"**
- ✅ **Ignorar**: Métricas internas de Apple, solo en debug

**Proyecto no abre en Xcode**
- ❌ **Solución**: Usar Método 1 (crear proyecto nuevo y copiar archivos)

**Pantalla en blanco o "Hello World"**
- ❌ **Causa**: GameViewController no cargó MainMenuScene correctamente
- ✅ **Solución**: Verificar que GameViewController.swift esté reemplazado

**Controles no responden**
- ❌ **Causa**: Física no configurada o escena no detecta toques
- ✅ **Solución**: Verificar que GameScene tenga `handleTouches()` implementado

### Debug y Testing

**En Simulador**:
- Funcionamiento básico OK
- Controles táctiles simulados con mouse
- Rendimiento puede ser diferente

**En Dispositivo Real** (recomendado):
- Experiencia táctil completa  
- Rendimiento real del juego
- Test de orientación landscape

## 🎯 Roadmap y Mejoras Futuras

### v1.1 (Próxima versión)
- [ ] Sonidos y efectos de audio
- [ ] Haptic feedback para iPhone
- [ ] Más tipos de power-ups
- [ ] Partículas más avanzadas

### v1.2 
- [ ] Boss battles cada 5 oleadas
- [ ] Sistema de upgrades persistente
- [ ] Múltiples tipos de enemigos

### v2.0
- [ ] Modo multijugador local
- [ ] Campanha con historia
- [ ] Personalización de naves

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver archivo LICENSE para detalles.

## 🙋‍♂️ Soporte

Si encuentras problemas:

1. **Verifica** que estés usando Xcode 15+ con iOS 17+
2. **Intenta** el Método 1 de instalación (crear proyecto nuevo)
3. **Revisa** que todos los archivos Swift estén agregados al target
4. **Confirma** orientación landscape en configuración del proyecto

---

**¡Disfruta destruyendo naves enemigas en el espacio retro-neón! 🚀✨**