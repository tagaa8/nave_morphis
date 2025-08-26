import UIKit

class VirtualJoystick3D: UIView {
    
    // MARK: - Properties
    weak var delegate: VirtualJoystick3DDelegate?
    
    private var knobView: UIView!
    private var knobCenter: CGPoint!
    private var maxDistance: CGFloat!
    private var currentDirection: CGPoint = .zero
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupJoystick()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupJoystick()
    }
    
    private func setupJoystick() {
        backgroundColor = UIColor.white.withAlphaComponent(0.2)
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = 3
        layer.borderColor = UIColor.cyan.withAlphaComponent(0.6).cgColor
        
        knobCenter = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        maxDistance = (bounds.width / 2) - 20
        
        knobView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        knobView.backgroundColor = UIColor.cyan
        knobView.layer.cornerRadius = 20
        knobView.center = knobCenter
        knobView.layer.borderWidth = 2
        knobView.layer.borderColor = UIColor.white.cgColor
        
        addSubview(knobView)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetJoystick()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetJoystick()
    }
    
    private func handleTouch(_ touch: UITouch) {
        let touchLocation = touch.location(in: self)
        let distance = sqrt(pow(touchLocation.x - knobCenter.x, 2) + pow(touchLocation.y - knobCenter.y, 2))
        
        if distance <= maxDistance {
            knobView.center = touchLocation
        } else {
            let angle = atan2(touchLocation.y - knobCenter.y, touchLocation.x - knobCenter.x)
            let constrainedX = knobCenter.x + cos(angle) * maxDistance
            let constrainedY = knobCenter.y + sin(angle) * maxDistance
            knobView.center = CGPoint(x: constrainedX, y: constrainedY)
        }
        
        updateDirection()
    }
    
    private func updateDirection() {
        let deltaX = knobView.center.x - knobCenter.x
        let deltaY = knobView.center.y - knobCenter.y
        
        let normalizedX = Float(deltaX / maxDistance)
        let normalizedZ = Float(-deltaY / maxDistance)
        
        currentDirection = CGPoint(x: CGFloat(normalizedX), y: CGFloat(normalizedZ))
        
        delegate?.joystickMoved(x: normalizedX, z: normalizedZ)
    }
    
    private func resetJoystick() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.knobView.center = self.knobCenter
        }
        
        currentDirection = .zero
        delegate?.joystickMoved(x: 0, z: 0)
    }
    
    // MARK: - Public Methods
    func getCurrentDirection() -> (x: Float, z: Float) {
        return (Float(currentDirection.x), Float(currentDirection.y))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        knobCenter = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        maxDistance = (bounds.width / 2) - 20
        
        if knobView != nil {
            knobView.center = knobCenter
        }
    }
}