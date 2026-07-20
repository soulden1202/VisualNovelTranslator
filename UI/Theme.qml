import QtQuick

// Central design tokens for the flat/minimal theme: one bold accent color,
// solid flat surfaces (no shadows/blur/gradients), small consistent radii.
// Instantiate locally where needed, e.g. `Theme { id: theme }`, and reference
// theme.accent, theme.bgSurface, etc. Kept as a plain QtObject rather than a
// pragma Singleton to avoid module-registration edge cases.
QtObject {
    // Backgrounds
    readonly property color bgBase: "#121214"
    readonly property color bgSurface: "#1B1B1F"
    readonly property color bgSurfaceAlt: "#232328"
    readonly property color bgSurfaceRaised: "#28282E"

    // Borders
    readonly property color border: "#2C2C33"
    readonly property color borderStrong: "#3A3A42"

    // Single bold accent, used sparingly (primary actions, focus, active state)
    readonly property color accent: "#4C8DFF"
    readonly property color accentHover: "#6B9FFF"
    readonly property color accentPressed: "#3D74D6"
    readonly property color accentMuted: "#24344F"

    // Semantic colors -- reserved for notifications/status, not decoration
    readonly property color success: "#3ED598"
    readonly property color danger: "#FF5C5C"
    readonly property color dangerHover: "#FF7070"
    readonly property color dangerPressed: "#E24545"
    readonly property color info: accent

    // Text
    readonly property color textPrimary: "#F2F2F5"
    readonly property color textSecondary: "#9A9AA5"
    readonly property color textMuted: "#65656F"
    readonly property color textOnAccent: "#0B0F17"

    // Shape / spacing
    readonly property int radiusSm: 4
    readonly property int radiusMd: 6
    readonly property int radiusLg: 10
    readonly property int spacingXs: 6
    readonly property int spacingSm: 10
    readonly property int spacingMd: 16
    readonly property int spacingLg: 24

    // Motion
    readonly property int durationFast: 120
}
