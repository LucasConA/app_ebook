import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-tabs',
  templateUrl: 'tabs.page.html',
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class TabsPage {

  isDark = false;

  constructor() {

    const theme = localStorage.getItem('theme');

    if (theme === 'dark') {
      document.body.classList.add('dark');
      this.isDark = true;
    }

  }

  toggleTheme() {

    this.isDark = !this.isDark;

    if (this.isDark) {
      document.body.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    } else {
      document.body.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    }

  }

}