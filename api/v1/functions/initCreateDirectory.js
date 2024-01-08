const fs = require('fs');
const util = require('util');

const mkdirAsync = util.promisify(fs.mkdir);

const createDirectories = async () => {
  try {
    await mkdirAsync('./upload', { recursive: true });
    await mkdirAsync('./upload/low', { recursive: true });
    await mkdirAsync('./upload/original', { recursive: true });
  } catch (error) {
    console.error('Error creating directories:', error.message);
  }
};

module.exports = createDirectories;
