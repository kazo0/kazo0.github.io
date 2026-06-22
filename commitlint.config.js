module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // Allow any subject case (e.g. "fix: Add thing"); the type itself stays lowercase.
    'subject-case': [0],
  },
};
