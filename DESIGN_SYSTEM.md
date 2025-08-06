# Rysk Design System

## 🎨 Color Palette

### Primary Colors

```dart
// Primary Blue
Color(0xFF3B82F6)  // Main brand blue
Color(0xFF1D4ED8)  // Darker blue for gradients

// Blue variants
Color(0xFF60A5FA)  // Light blue
Color(0xFF2563EB)  // Medium blue
Color(0xFF1E40AF)  // Dark blue
```

### Neutral Colors

```dart
// Text Colors
Color(0xFF1F2937)  // Primary text (dark gray)
Color(0xFF374151)  // Secondary text
Color(0xFF6B7280)  // Muted text (medium gray)
Color(0xFF9CA3AF)  // Placeholder text
Color(0xFFD1D5DB)  // Disabled text

// Background Colors
Color(0xFFFFFFFF)  // White background
Color(0xFFF9FAFB)  // Light gray background
Color(0xFFF3F4F6)  // Input backgrounds
Color(0xFFE5E7EB)  // Borders and dividers
```

### Status Colors

```dart
// Success (Green)
Color(0xFF10B981)  // Success primary
Color(0xFF059669)  // Success dark

// Warning (Orange/Yellow)
Color(0xFFF59E0B)  // Warning primary
Color(0xFFD97706)  // Warning dark

// Error (Red)
Color(0xFFEF4444)  // Error primary
Color(0xFFDC2626)  // Error dark

// Purple (High risk)
Color(0xFF8B5CF6)  // Purple primary
Color(0xFF7C3AED)  // Purple dark
```

## 🌈 Gradients

### Primary Gradient

```dart
LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Logo/Icon Gradient

```dart
LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Risk Level Gradients

```dart
// Low Risk (Green)
LinearGradient(
  colors: [Color(0xFF10B981), Color(0xFF059669)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Medium Risk (Orange)
LinearGradient(
  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// High Risk (Red)
LinearGradient(
  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Critical Risk (Purple)
LinearGradient(
  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

## 🎯 Shadows & Effects

### Primary Button Shadow

```dart
BoxShadow(
  color: Color(0xFF3B82F6).withOpacity(0.4),
  blurRadius: 20,
  offset: Offset(0, 8),
)
```

### Card/Container Shadow

```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 10,
  offset: Offset(0, 4),
)
```

### Logo Glow Effect

```dart
BoxShadow(
  color: Color(0xFF3B82F6).withOpacity(0.3),
  blurRadius: 20,
  offset: Offset(0, 10),
)
```

## 📐 Border Radius

### Standard Radius Values

```dart
BorderRadius.circular(8)   // Small elements
BorderRadius.circular(12)  // Cards, containers
BorderRadius.circular(16)  // Input fields
BorderRadius.circular(20)  // Large containers
BorderRadius.circular(28)  // Pill-shaped buttons
BorderRadius.circular(32)  // Very rounded elements
```

## 📝 Typography (Inter Font)

### Headings

```dart
// Large Heading
GoogleFonts.inter(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1F2937),
)

// Medium Heading
GoogleFonts.inter(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F2937),
)

// Small Heading
GoogleFonts.inter(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Color(0xFF1F2937),
)
```

### Body Text

```dart
// Body Large
GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w400,
  color: Color(0xFF374151),
)

// Body Medium
GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Color(0xFF374151),
)

// Body Small
GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0xFF6B7280),
)
```

### Buttons

```dart
// Primary Button Text
GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.white,
)

// Secondary Button Text
GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Color(0xFF1F2937),
)
```

## 🎨 Button Styles

### Primary Button (Pill-shaped with Gradient)

```dart
Container(
  width: double.infinity,
  height: 56,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    gradient: LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF3B82F6).withOpacity(0.4),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
    child: Text(
      'Button Text',
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  ),
)
```

### Secondary Button (Outlined)

```dart
Container(
  width: double.infinity,
  height: 56,
  child: OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Color(0xFFE5E7EB)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Colors.white,
    ),
    child: Text(
      'Button Text',
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
      ),
    ),
  ),
)
```

## 📱 Input Fields

### Standard Text Input

```dart
TextFormField(
  style: GoogleFonts.inter(),
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Placeholder text',
    prefixIcon: Icon(Icons.icon_name),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
    ),
    filled: true,
    fillColor: Color(0xFFF9FAFB),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
)
```

## 🏗️ Layout Standards

### Spacing Scale

```dart
4.0   // Extra small
8.0   // Small
12.0  // Medium small
16.0  // Medium
20.0  // Medium large
24.0  // Large
32.0  // Extra large
40.0  // XX Large
48.0  // XXX Large
64.0  // XXXX Large
```

### Container Padding

```dart
EdgeInsets.all(16)                           // Standard padding
EdgeInsets.symmetric(horizontal: 32.0)       // Login/Auth screens
EdgeInsets.symmetric(horizontal: 16.0)       // Content screens
EdgeInsets.symmetric(vertical: 8.0)          // List items
```

## 💡 Usage Guidelines

1. **Always use Inter font** via `GoogleFonts.inter()`
2. **Consistent border radius** - use the standard values above
3. **Primary blue gradient** for main CTAs and branding
4. **Pill-shaped buttons** (28px radius) for primary actions
5. **Subtle shadows** for depth and hierarchy
6. **Consistent spacing** using the spacing scale
7. **Risk color coding** - green (low), orange (medium), red (high), purple (critical)

## 🎨 Quick Color Reference

| Usage            | Hex Code  | Dart Color          |
| ---------------- | --------- | ------------------- |
| Primary Brand    | `#3B82F6` | `Color(0xFF3B82F6)` |
| Primary Dark     | `#1D4ED8` | `Color(0xFF1D4ED8)` |
| Text Primary     | `#1F2937` | `Color(0xFF1F2937)` |
| Text Muted       | `#6B7280` | `Color(0xFF6B7280)` |
| Border/Divider   | `#E5E7EB` | `Color(0xFFE5E7EB)` |
| Background Light | `#F9FAFB` | `Color(0xFFF9FAFB)` |
| Success          | `#10B981` | `Color(0xFF10B981)` |
| Warning          | `#F59E0B` | `Color(0xFFF59E0B)` |
| Error            | `#EF4444` | `Color(0xFFEF4444)` |
| Critical         | `#8B5CF6` | `Color(0xFF8B5CF6)` |
