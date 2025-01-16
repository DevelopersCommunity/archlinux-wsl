import { argbFromHex, hexFromArgb, themeFromSourceColor } from "@material/material-color-utilities";

/** @enum {string} */
const ColorName = {
  black: 'black',
  red: 'red',
  green: 'green',
  yellow: 'yellow',
  blue: 'blue',
  purple: 'purple',
  cyan: 'cyan',
  white: 'white',
  brightBlack: 'brightBlack',
  brightRed: 'brightRed',
  brightGreen: 'brightGreen',
  brightYellow: 'brightYellow',
  brightBlue: 'brightBlue',
  brightPurple: 'brightPurple',
  brightCyan: 'brightCyan',
  brightWhite: 'brightWhite',
  background: 'background',
  selectionBackground: 'selectionBackground',
  foreground: 'foreground',
}

class Profile {
  /**
   * @param {string} colorScheme
   */
  constructor(colorScheme) {
    this.colorScheme = colorScheme;
  }
}

class Scheme {
  /**
   * @param {string} name
   * @param {import("@material/material-color-utilities").Theme} theme
   * @param {boolean} isDark
   */
  constructor(name, theme, isDark) {
    const scheme = isDark ? theme.schemes.dark : theme.schemes.light;

    this.name = Scheme.themeNameMode(name, isDark);
    this.background = hexFromArgb(scheme.surface);
    this.selectionBackground = hexFromArgb(scheme.surfaceVariant);
    this.foreground = hexFromArgb(scheme.onSurface);
    this.black = Scheme.findColor(theme.customColors, ColorName.black, isDark);
    this.red = Scheme.findColor(theme.customColors, ColorName.red, isDark);
    this.green = Scheme.findColor(theme.customColors, ColorName.green, isDark);
    this.yellow = Scheme.findColor(theme.customColors, ColorName.yellow, isDark);
    this.blue = Scheme.findColor(theme.customColors, ColorName.blue, isDark);
    this.purple = Scheme.findColor(theme.customColors, ColorName.purple, isDark);
    this.cyan = Scheme.findColor(theme.customColors, ColorName.cyan, isDark);
    this.white = Scheme.findColor(theme.customColors, ColorName.white, isDark);
    this.brightBlack = Scheme.findColor(theme.customColors, ColorName.brightBlack, isDark);
    this.brightRed = Scheme.findColor(theme.customColors, ColorName.brightRed, isDark);
    this.brightGreen = Scheme.findColor(theme.customColors, ColorName.brightGreen, isDark);
    this.brightYellow = Scheme.findColor(theme.customColors, ColorName.brightYellow, isDark);
    this.brightBlue = Scheme.findColor(theme.customColors, ColorName.brightBlue, isDark);
    this.brightPurple = Scheme.findColor(theme.customColors, ColorName.brightPurple, isDark);
    this.brightCyan = Scheme.findColor(theme.customColors, ColorName.brightCyan, isDark);
    this.brightWhite = Scheme.findColor(theme.customColors, ColorName.brightWhite, isDark);
  }

  /**
   * @param {string} themeName
   * @param {boolean} isDark
   */
  static themeNameMode(themeName, isDark) {
    return `${themeName} ${isDark ? 'Dark' : 'Light'}`;
  }

  /**
   * @param {Array<import("@material/material-color-utilities").CustomColorGroup>} customColors
   * @param {ColorName} color
   * @param {boolean} isDark
   */
  static findColor(customColors, color, isDark) {
    const customColor = customColors.find(
      (value, _index, _obj) => value.color.name == color);
    if (customColor === undefined) {
      throw new Error(`Color ${color} not found`);
    }

    return isDark ? hexFromArgb(customColor.dark.color) : hexFromArgb(customColor.light.color);
  }
}

class WindowsTerminalProfile {
  /**
   * @param {Array<Profile>} profiles
   * @param {Array<Scheme>} schemes
   */
  constructor(profiles, schemes) {
    this.profiles = profiles;
    this.schemes = schemes;
  }
}

function main() {
  const themeName = 'Arch Linux Material';

  // Arch Linux logo blue color.
  const sourceColor = argbFromHex('#1793d1');

  // Get the theme from a hex color.
  const theme = themeFromSourceColor(sourceColor,
    // Colors taken from xterm.
    // https://github.com/xterm-x11/xterm-snapshots/blob/5b7a08a3482b425c97610190228e58b51ac6c39b/vttests/88colors2.pl#L160-L175
    [
      {
        name: ColorName.black,
        value: argbFromHex("#000000"),
        blend: true,
      },
      {
        name: ColorName.red,
        value: argbFromHex("#CD0000"),
        blend: true,
      },
      {
        name: ColorName.green,
        value: argbFromHex("#00CD00"),
        blend: true,
      },
      {
        name: ColorName.yellow,
        value: argbFromHex("#CDCD00"),
        blend: true,
      },
      {
        name: ColorName.blue,
        value: argbFromHex("#0000EE"),
        blend: true,
      },
      {
        name: ColorName.purple,
        value: argbFromHex("#CD00CD"),
        blend: true,
      },
      {
        name: ColorName.cyan,
        value: argbFromHex("#00CDCD"),
        blend: true,
      },
      {
        name: ColorName.white,
        value: argbFromHex("#E5E5E5"),
        blend: true,
      },
      {
        name: ColorName.brightBlack,
        value: argbFromHex("#7F7F7F"),
        blend: true,
      },
      {
        name: ColorName.brightRed,
        value: argbFromHex("#FF0000"),
        blend: true,
      },
      {
        name: ColorName.brightGreen,
        value: argbFromHex("#00FF00"),
        blend: true,
      },
      {
        name: ColorName.brightYellow,
        value: argbFromHex("#FFFF00"),
        blend: true,
      },
      {
        name: ColorName.brightBlue,
        value: argbFromHex("#5C5CFF"),
        blend: true,
      },
      {
        name: ColorName.brightPurple,
        value: argbFromHex("#FF00FF"),
        blend: true,
      },
      {
        name: ColorName.brightCyan,
        value: argbFromHex("#00FFFF"),
        blend: true,
      },
      {
        name: ColorName.brightWhite,
        value: argbFromHex("#FFFFFF"),
        blend: true,
      },
    ]);

  const profile = new WindowsTerminalProfile(
    new Array(new Profile(Scheme.themeNameMode(themeName, true))),
    new Array(new Scheme(themeName, theme, true), new Scheme(themeName, theme, false)));

  console.log(JSON.stringify(profile, null, 2));
}

main();
