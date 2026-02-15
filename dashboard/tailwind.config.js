/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './node_modules/@tremor/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Tremor default colors
        tremor: {
          brand: {
            faint: '#10b981',
            muted: '#059669',
            subtle: '#047857',
            DEFAULT: '#065f46',
            emphasis: '#064e3b',
            inverted: '#ffffff',
          },
          background: {
            muted: '#0a0a0a',
            subtle: '#171717',
            DEFAULT: '#0a0a0a',
            emphasis: '#262626',
          },
          border: {
            DEFAULT: '#262626',
          },
          ring: {
            DEFAULT: '#10b981',
          },
          content: {
            subtle: '#737373',
            DEFAULT: '#a3a3a3',
            emphasis: '#e5e5e5',
            strong: '#fafafa',
            inverted: '#0a0a0a',
          },
        },
      },
    },
  },
  plugins: [],
};
