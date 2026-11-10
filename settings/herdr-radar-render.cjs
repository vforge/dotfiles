'use strict';

// Sidebar-only cleanup; leave terminal titles and agent state markers intact.
const AGENT_PREFIX = /^(?:OC\s+-\s+|(?:[\u2800-\u28ff]\s+)?(?:π|pi)\s+[-!]\s+)/i;

module.exports = {
  title(text) {
    if (typeof text !== 'string') return text;
    const clean = text.replace(AGENT_PREFIX, '');
    return clean.trim() ? clean : text;
  },
};
