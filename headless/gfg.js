const { chromium } = require('playwright');

(async () => {
  const username = process.argv[2];
  if (!username) {
    console.error('Username missing');
    process.exit(1);
  }

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  try {
    await page.goto(
      `https://auth.geeksforgeeks.org/user/${username}/`,
      { waitUntil: 'networkidle' }
    );

    await page.waitForTimeout(3000);

    const data = await page.evaluate(() => {
      const getStatByLabel = (label) => {
        const elements = Array.from(document.querySelectorAll('*'));

        for (const el of elements) {
          if (el.innerText && el.innerText.trim() === label) {
            // Case 1: direct sibling
            let valueEl = el.nextElementSibling;
            if (valueEl) {
              let match = valueEl.innerText.match(/\d+/);
              if (match) return parseInt(match[0], 10);
            }

            // Case 2: value inside same parent (GFG layout)
            const parent = el.parentElement;
            if (parent) {
              const text = parent.innerText;
              const match = text.match(new RegExp(label + '[^\\d]*(\\d+)', 'i'));
              if (match) return parseInt(match[1], 10);
            }
          }
        }
        return null;
      };

      return {
        problemsSolved: getStatByLabel('Problems Solved'),
        codingScore: getStatByLabel('Coding Score'),
      };
    });

    console.log(JSON.stringify({
      success: true,
      data,
    }));
  } catch (err) {
    console.log(JSON.stringify({
      success: false,
      error: err.message,
    }));
  } finally {
    await browser.close();
  }
})();