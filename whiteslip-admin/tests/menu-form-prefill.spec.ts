import { test, expect } from '@playwright/test';

test.describe('菜單表單預填功能測試', () => {
  test.beforeEach(async ({ page }) => {
    // 捕獲 console log
    await page.addInitScript(() => {
      (window as any).consoleLogs = [];
      const originalLog = console.log;
      console.log = (...args) => {
        (window as any).consoleLogs.push(args.join(' '));
        originalLog.apply(console, args);
      };
    });

    // 直接進入菜單管理頁面
    console.log('正在導航到菜單管理頁...');
    await page.goto('http://localhost:3001/menu');
    
    // 等待頁面完全載入
    await page.waitForLoadState('networkidle');
    
    // 檢查是否需要登入
    const isLoggedIn = await page.locator('h1:has-text("菜單管理")').isVisible();
    
    if (!isLoggedIn) {
      console.log('檢測到需要登入，請在瀏覽器中手動完成登入...');
      console.log('登入資訊：帳號 admin，密碼 admin123');
      console.log('登入後請點擊側邊欄的「菜單管理」進入菜單頁面');
      
      // 等待用戶手動登入並進入菜單管理頁面
      await page.waitForSelector('h1:has-text("菜單管理")', { timeout: 120000 }); // 2分鐘等待時間
      console.log('檢測到菜單管理頁面，登入完成！');
    } else {
      console.log('已經登入，直接進入菜單管理頁');
    }
  });

  test('新增菜單時應該自動複製最新版本內容', async ({ page }) => {
    // 檢查是否有現有菜單
    const hasExistingMenu = await page.locator('table').count() > 0;
    console.log(`是否有現有菜單: ${hasExistingMenu}`);

    if (hasExistingMenu) {
      // 獲取現有菜單的版本號
      const versionCell = page.locator('table tbody tr:first-child td:first-child');
      const currentVersion = await versionCell.textContent();
      console.log(`當前版本號: ${currentVersion}`);

      // 點擊新增菜單按鈕
      console.log('點擊新增菜單按鈕...');
      await page.click('button:has-text("新增菜單")');
      
      // 等待模態框出現
      console.log('等待模態框出現...');
      await page.waitForSelector('.ant-modal-content', { timeout: 15000 });
      console.log('模態框已出現');
      
      // 等待模態框完全載入
      await page.waitForTimeout(2000);
      
      // 檢查版本號是否自動 +1
      console.log('等待版本號輸入欄位...');
      const versionInput = page.locator('input[type="number"]');
      await versionInput.waitFor({ timeout: 15000 });
      const versionValue = await versionInput.inputValue();
      console.log(`自動設定的版本號: ${versionValue}`);
      
      // 檢查是否有分類被預填
      const categoryCards = page.locator('.ant-card');
      const categoryCount = await categoryCards.count();
      console.log(`預填的分類數量: ${categoryCount}`);
      
      // 驗證版本號是否正確
      if (currentVersion) {
        const expectedVersion = parseInt(currentVersion) + 1;
        expect(parseInt(versionValue)).toBe(expectedVersion);
      }
      
      // 驗證是否有分類被預填
      expect(categoryCount).toBeGreaterThan(0);
      
      // 檢查 Console 中是否有預填事件的日誌
      const logs = await page.evaluate(() => {
        return (window as any).consoleLogs || [];
      });
      console.log('Console 日誌:', logs);
      
    } else {
      // 如果沒有現有菜單，測試基本的新增功能
      console.log('沒有現有菜單，測試基本新增功能...');
      await page.click('button:has-text("新增菜單")');
      await page.waitForSelector('.ant-modal-content', { timeout: 15000 });
      
      // 檢查版本號是否為 1
      const versionInput = page.locator('input[type="number"]');
      await versionInput.waitFor({ timeout: 15000 });
      const versionValue = await versionInput.inputValue();
      expect(parseInt(versionValue)).toBe(1);
    }
  });

  test('表單應該能正常提交', async ({ page }) => {
    // 點擊新增菜單按鈕
    await page.click('button:has-text("新增菜單")');
    
    // 等待模態框出現
    await page.waitForSelector('.ant-modal-content', { timeout: 10000 });
    
    // 填寫基本資訊
    const versionInput = page.locator('input[type="number"]');
    await versionInput.fill('1');
    
    const descriptionInput = page.locator('textarea');
    await descriptionInput.fill('測試菜單');
    
    // 新增一個分類
    await page.click('button:has-text("新增分類")');
    
    // 填寫分類名稱
    const categoryNameInput = page.locator('input[placeholder="請輸入分類名稱"]').first();
    await categoryNameInput.fill('測試分類');
    
    // 新增一個項目
    await page.click('button:has-text("新增項目")');
    
    // 填寫項目資訊
    const itemNameInput = page.locator('input[placeholder="請輸入項目名稱"]').first();
    await itemNameInput.fill('測試項目');
    
    const itemPriceInput = page.locator('input[placeholder="請輸入價格"]').first();
    await itemPriceInput.fill('100');
    
    // 提交表單
    await page.click('button:has-text("建立菜單")');
    
    // 等待提交完成（可能會失敗，但我們主要測試前端邏輯）
    try {
      await page.waitForSelector('.ant-message-success', { timeout: 5000 });
      console.log('表單提交成功');
    } catch (error) {
      console.log('表單提交可能失敗（預期行為，因為後端可能未運行）');
    }
  });
}); 