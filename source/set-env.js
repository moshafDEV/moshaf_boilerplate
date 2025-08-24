const fs = require('fs');
const path = require('path');
const os = require('os');
const execSync = require('child_process').execSync;
const readline = require('readline');

const flavor = process.argv[2];  // Get the flavor argument (dev/prod)
const envFileMap = {
  dev: '.env.dev',
  prod: '.env.prod',
};

const envFile = envFileMap[flavor];

if (!envFile) {
  console.log('Unrecognized flavor. Use "dev" or "prod".');
  process.exit(1);
}

// Copy the .env file according to the selected flavor
fs.copyFileSync(path.join(__dirname, envFile), path.join(__dirname, '.env'));
console.log(`Using ${envFile}`);

// // Define the location and flavor for Info.plist and GoogleService-Info.plist files
// const plistFileMap = {
//   dev: 'Info-dev.plist',
//   prod: 'Info-prod.plist',
// };

const googleServiceFileMap = {
  dev: 'GoogleService-Info-dev.plist',
  prod: 'GoogleService-Info-prod.plist',
};

// const plistFile = plistFileMap[flavor];
const googleServiceFile = googleServiceFileMap[flavor];
const googleServiceFilePath = path.join(__dirname, 'ios/Runner', googleServiceFile);

if (!googleServiceFile || !fs.existsSync(googleServiceFilePath)) {
  console.log('Plist or GoogleService-Info file not found for this flavor.');
  // process.exit(1);
} else {
  // // Copy the Info.plist file according to the selected flavor
  // fs.copyFileSync(path.join(__dirname, 'ios/Runner', plistFile), path.join(__dirname, 'ios/Runner/Info.plist'));
  // console.log(`Using ${plistFile} for Info.plist`);
  
  // Copy the GoogleService-Info.plist file according to the selected flavor
  fs.copyFileSync(googleServiceFilePath, path.join(__dirname, 'ios/Runner/GoogleService-Info.plist'));
  console.log(`Using ${googleServiceFile} for GoogleService-Info.plist`);
}


// Run the build_runner command (Flutter) after replacing the .env file
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

let countdown = 5;
let answered = false;

const timer = setInterval(() => {
  process.stdout.write(`\rRun build_runner? (y/n): (auto n in ${countdown}s) `);
  countdown--;
  if (countdown < 0) {
    clearInterval(timer);
    rl.close();
    process.exit();
  }
}, 1000);

rl.question('Run build_runner? (y/n): ', (answer) => {
  answered = true;
  clearInterval(timer);
  if (answer.toLowerCase() === 'y') {
    try {
      execSync('dart run build_runner build --delete-conflicting-outputs', { stdio: 'inherit' });
      process.exit();
    } catch (err) {
      console.error('Failed to run build_runner:', err);
      process.exit();
    }
  } else {
    console.log('Skipped build_runner.');
    process.exit();
  }
});
