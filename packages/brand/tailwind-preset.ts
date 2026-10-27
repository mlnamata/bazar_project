import type { Config } from 'tailwindcss';

/** Sdílený Tailwind preset – používá aplikace i plugin. Barvy čte z tokens.css. */
const c = (name: string) => `hsl(var(--${name}) / <alpha-value>)`;

const preset: Partial<Config> = {
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        background: c('background'),
        surface: c('surface'),
        foreground: c('foreground'),
        muted: { DEFAULT: c('muted'), foreground: c('muted-foreground') },
        border: c('border'),
        ring: c('ring'),
        primary: { DEFAULT: c('primary'), foreground: c('primary-foreground') },
        secondary: { DEFAULT: c('secondary'), foreground: c('secondary-foreground') },
        accent: { DEFAULT: c('accent'), foreground: c('accent-foreground') },
        success: c('success'),
        warning: c('warning'),
        danger: c('danger'),
        info: c('info'),
        status: {
          buyout: c('status-buyout'),
          preparation: c('status-preparation'),
          ready: c('status-ready'),
          advertised: c('status-advertised'),
          reserved: c('status-reserved'),
          sold: c('status-sold'),
          inactive: c('status-inactive'),
        },
      },
      borderRadius: { sm: 'var(--radius-sm)', DEFAULT: 'var(--radius)', lg: 'var(--radius-lg)' },
      fontFamily: { sans: ['var(--font-sans)'], display: ['var(--font-display)'] },
      boxShadow: { card: 'var(--shadow-card)', pop: 'var(--shadow-pop)' },
    },
  },
};

export default preset;
