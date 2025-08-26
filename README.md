# Nave Morphis

Un juego de combate espacial retro-neón futurista para iOS construido con SpriteKit.

## 🚀 Características Principales

### Gameplay Core
- **Controles twin-stick**: Lado izquierdo para movimiento, lado derecho para disparo
- **Auto-fire**: Disparo automático continuo cuando mantienes presionado el lado derecho
- **Power-ups**: Los enemigos destruidos tienen 30% de posibilidad de soltar power-ups
- **Sistema de vidas**: 3 vidas iniciales, los power-ups te dan vidas extra (máximo 5)
- **Puntuación**: 100 puntos por enemigo, 50 por power-up, progresión de oleadas
- **High Score**: Sistema de puntaje máximo persistente

### Efectos Visuales
- **Campo de estrellas animado**: 200 estrellas con movimiento parallax
- **Nebulosa de fondo**: Efecto púrpura translúcido en movimiento continuo  
- **Naves con glow**: Efectos de brillo cyan (jugador) y rojo (enemigos)
- **Explosiones multicapa**: Explosión principal + 8 partículas chispeantes
- **Power-ups animados**: Rotación, flotación y efectos de brillo magenta
- **Flash de disparo**: Efecto visual en el cañón al disparar

### IA Enemiga Inteligente
- **Spawning dinámico**: Los enemigos aparecen desde los bordes de la pantalla
- **Targeting inteligente**: Los enemigos se mueven hacia tu posición actual
- **Spawn continuo**: Máximo 5 enemigos en pantalla, respawn cada 2 segundos
- **Colisiones realistas**: Física precisa para todas las interacciones

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

### Método 1: Crear Proyecto Nuevo (Recomendado)

1. **Crear proyecto en Xcode**:
   - File → New → Project
   - iOS → Game
   - Product Name: `NaveMorphis`
   - Bundle ID: `com.tagaa8.NaveMorphis`  
   - Language: Swift
   - Game Technology: **SpriteKit**
   - Deployment Target: **iOS 17.0**

2. **Configurar orientación**:
   - Seleccionar target del proyecto
   - Deployment Info → Device Orientation
   - Desmarcar Portrait, dejar solo Landscape Left y Right

3. **Copiar archivos del repositorio**:
   ```bash
   git clone git@github.com:tagaa8/nave_morphis.git
   cd nave_morphis
   ```

4. **Reemplazar archivos en Xcode**:
   - `AppDelegate.swift` → Copiar desde el repositorio
   - `GameViewController.swift` → Reemplazar con el del repo
   - Crear nuevos archivos Swift y copiar el contenido:
     - `MainMenuScene.swift`
     - `GameScene.swift` 
     - `GameOverScene.swift`

5. **Assets** (opcional):
   - Copiar carpeta completa `Assets.xcassets` del repo
   - O usar los assets por defecto de SpriteKit

### Método 2: Importar Proyecto Completo

Si prefieres importar todo el proyecto:
```bash
git clone git@github.com:tagaa8/nave_morphis.git
cd nave_morphis
open NaveMorphis.xcodeproj
```

**Nota**: Si obtienes errores de proyecto corrupto, usa el Método 1.

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
├── AppDelegate.swift              # Entrada principal de la app
├── GameViewController.swift       # Controlador principal, maneja orientación
├── Sources/
│   └── Scenes/
│       ├── MainMenuScene.swift    # Menú principal con estrellas animadas
│       ├── GameScene.swift        # Lógica principal del juego
│       └── GameOverScene.swift    # Pantalla final con high score
└── Assets.xcassets/               # Sprites y recursos gráficos
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