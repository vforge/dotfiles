'use strict';

const assert = require('node:assert/strict');
const { test } = require('node:test');
const { title } = require('../settings/herdr-radar-render.cjs');

test('strips OpenCode and Pi prefixes from sidebar titles', () => {
  for (const prefix of ['OC - ', 'π - ', 'pi - ', 'Pi - ', 'π ! ', '⠋ π - ']) {
    assert.equal(title(`${prefix}Fix tests - repo`), 'Fix tests - repo');
  }
});

test('preserves ordinary titles, embedded prefixes, and empty labels', () => {
  for (const text of ['Fix tests', 'Fix pi - parsing', 'pipeline', 'π calculator', 'π - ', '', null, undefined]) {
    assert.equal(title(text), text);
  }
});
