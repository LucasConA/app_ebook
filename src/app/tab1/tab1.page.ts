import { Component, OnInit } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { BookService, Livro } from '../service/book';

@Component({
  selector: 'app-tab1',
  standalone: true,
  imports: [IonicModule, FormsModule, CommonModule],
  templateUrl: './tab1.page.html',
})
export class Tab1Page implements OnInit {

  titulo: string = '';
  autor: string = '';
  livros: Livro[] = [];

  constructor(private bookService: BookService) {}

  async ngOnInit() {
    this.livros = await this.bookService.listar();
  }

  async adicionarLivro() {
    if (!this.titulo || !this.autor) return;

    await this.bookService.adicionar({
      titulo: this.titulo,
      autor: this.autor
    });

    this.livros = await this.bookService.listar();

    this.titulo = '';
    this.autor = '';
  }
}