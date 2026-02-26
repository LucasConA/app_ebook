import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { BookService } from '../service/book';

@Component({
  selector: 'app-tab1',
  standalone: true,
  imports: [IonicModule, FormsModule, CommonModule],
  templateUrl: './tab1.page.html',
})
export class Tab1Page {

  titulo: string = '';
  autor: string = '';

  constructor(private bookService: BookService) {}

  adicionarLivro() {

    if (!this.titulo || !this.autor) return;

    this.bookService.adicionar({
      titulo: this.titulo,
      autor: this.autor
    });

    this.titulo = '';
    this.autor = '';

    alert('Livro adicionado!');
  }
}