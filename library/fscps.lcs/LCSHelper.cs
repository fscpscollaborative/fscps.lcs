using System;
using System.Threading.Tasks;

using Microsoft.Playwright;

namespace fcsps.lcs
{
    public class LCSHelper
    {
        public async Task GetAuthorizationCookies()
        {
            // Initialize Playwright
            using var playwright = await Playwright.CreateAsync();

            // Launch a browser (Chromium, Firefox, or WebKit)
            var browser = await playwright.Chromium.LaunchAsync(new BrowserTypeLaunchOptions
            {
                Headless = false // Set to true for headless mode
            });

            // Create a new browser context and page
            var context = await browser.NewContextAsync();
            var page = await context.NewPageAsync();

            // Navigate to the Microsoft login page
            await page.GotoAsync("https://login.microsoftonline.com/");


            // Wait for navigation or redirection
            await page.WaitForNavigationAsync();

            // Save cookies or tokens
            var cookies = await context.CookiesAsync();
            foreach (var cookie in cookies)
            {
                Console.WriteLine($"Cookie: {cookie.Name} = {cookie.Value}");
            }

            // Close the browser
            await browser.CloseAsync();
        }

    }
}
