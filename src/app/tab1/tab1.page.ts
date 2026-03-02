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
  idioma: string = '';
  genero: string = '';
  tags: string = '';
  link: string = '';
  capaBase64: string = '';

  livros: Livro[] = [];

  constructor(private bookService: BookService) {}

  async ngOnInit() {
    this.livros = await this.bookService.listar();
  }

  async adicionarLivro() {
    if (!this.titulo || !this.autor) return;

    await this.bookService.adicionar({
      id: crypto.randomUUID(),
      titulo: this.titulo,
      autor: this.autor,
      idioma: this.idioma,
      genero: this.genero,
      tags: this.tags ? this.tags.split(',').map(t => t.trim()) : [],
      link: this.link,
      capa: this.capaBase64,
      criadoEm: new Date()
});
    this.livros = await this.bookService.listar();

    this.titulo = '';
    this.autor = '';
    this.idioma  = '';
    this.genero  = '';
    this.tags  = '';
    this.link  = '';
    this.capaBase64  = '';
  }
    onFileSelected(event: any) {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = () => {
      this.capaBase64 = reader.result as string;
    };

    reader.readAsDataURL(file);
}
}