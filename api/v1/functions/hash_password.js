async function hashPassword(password) {
  try {
    const bcryptHash = await Bun.password.hash(password, {
      algorithm: "bcrypt",
      cost: 4, // number between 4-31
    });
    return bcryptHash;
  } catch (error) {
    console.error(error);
    throw error;
  }
}

async function checkPassword(password, hash) {
  try {
    const isMatch = await Bun.password.verify(password, hash);
    return isMatch;
  } catch (error) {
    console.error(error);
    throw error;
  }
}

module.exports = { hashPassword, checkPassword };
