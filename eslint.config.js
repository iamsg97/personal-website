// @ts-check

// Import the tanstack config
// @ts-ignore
import { tanstackConfig } from '@tanstack/eslint-config'

/** @type {import('eslint').Linter.FlatConfig} */
const customConfig = {
  rules: {
    // Add any custom rules here
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-unused-vars': [
      'warn',
      {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
      },
    ],
    'import/prefer-default-export': 'off',
  },
}

export default [...tanstackConfig, customConfig]
