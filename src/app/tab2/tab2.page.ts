import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { CommonModule } from '@angular/common';
import { BookService, Livro } from '../service/book';

@Component({
  selector: 'app-tab2',
  standalone: true,
  imports: [IonicModule, CommonModule],
  templateUrl: './tab2.page.html',
})
export class Tab2Page {

  livros: Livro[] = [];

  constructor(private bookService: BookService) {}

  async ionViewWillEnter() {
    this.livros = await this.bookService.listar();
  }

  async removerLivro(index: number) {
  await this.bookService.remover(index);
  this.livros = await this.bookService.listar();
}
}

