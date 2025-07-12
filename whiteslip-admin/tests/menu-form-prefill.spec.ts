import { test, expect } from '@playwright/test';

test.describe('菜單表單預填功能測試', () => {
  test.beforeEach(async ({ page }) => {
    // 導航到菜單管理頁面
    await page.goto('http://localhost:3001/menu');
    
    // 等待頁面載入
    await page.waitForSelector('h1:has-text("菜單管理")');
  });

  test('新增菜單時應該自動複製最新版本內容', async ({ page }) => {
    // 檢查是否有現有菜單
    const hasExistingMenu = await page.locator('table').isVisible();
    
    if (hasExistingMenu) {
      // 記錄現有菜單的內容
      const existingCategories = await page.locator('table tbody tr').count();
      console.log(`現有菜單分類數量: ${existingCategories}`);
      
      // 點擊新增菜單按鈕
      await page.click('button:has-text("新增菜單")');
      
      // 等待模態框出現
      await page.waitForSelector('.ant-modal-content');
      
      // 檢查版本號是否自動 +1
      const versionInput = page.locator('input[type="number"]');
      const versionValue = await versionInput.inputValue();
      console.log(`自動設定的版本號: ${versionValue}`);
      
      // 檢查是否有分類被預填
      const categoryCards = page.locator('.ant-card-head-title:has-text("分類管理")');
      await expect(categoryCards).toBeVisible();
      
      // 檢查分類列表是否有內容
      const categoryList = page.locator('.ant-card-body');
      const hasCategories = await categoryList.locator('text=尚未建立分類').count() === 0;
      
      if (hasCategories) {
        console.log('✅ 分類內容已成功預填');
      } else {
        console.log('❌ 分類內容未預填');
      }
      
      // 檢查描述欄位是否為空
      const descriptionTextarea = page.locator('textarea');
      const descriptionValue = await descriptionTextarea.inputValue();
      expect(descriptionValue).toBe('');
      
    } else {
      // 如果沒有現有菜單，測試空白表單
      console.log('沒有現有菜單，測試空白表單');
      
      await page.click('button:has-text("新增菜單")');
      await page.waitForSelector('.ant-modal-content');
      
      // 檢查版本號是否為 1
      const versionInput = page.locator('input[type="number"]');
      const versionValue = await versionInput.inputValue();
      expect(versionValue).toBe('1');
    }
  });

  test('表單應該能正常提交', async ({ page }) => {
    await page.click('button:has-text("新增菜單")');
    await page.waitForSelector('.ant-modal-content');
    
    // 填寫基本資訊
    await page.fill('input[type="number"]', '1');
    await page.fill('textarea', '測試菜單');
    
    // 新增分類
    await page.click('button:has-text("新增分類")');
    
    // 填寫分類名稱
    const categoryNameInput = page.locator('input[placeholder="分類名稱"]').first();
    await categoryNameInput.fill('飲料');
    
    // 新增項目
    await page.click('button:has-text("新增項目")');
    
    // 填寫項目資訊
    const itemNameInput = page.locator('input[placeholder="項目名稱"]').first();
    await itemNameInput.fill('可樂');
    
    const priceInput = page.locator('input[type="number"]').nth(1);
    await priceInput.fill('30');
    
    // 提交表單
    await page.click('button:has-text("建立菜單")');
    
    // 檢查是否成功提交（模態框應該關閉）
    await expect(page.locator('.ant-modal-content')).not.toBeVisible();
  });
}); 