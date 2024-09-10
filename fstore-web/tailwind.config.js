/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/views/**/*.haml'],
  theme: {
    extend: {},
  },
  plugins: [require('@tailwindcss/forms'),require('@tailwindcss/typography'),],
}

