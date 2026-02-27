import { Injectable } from '@angular/core';

export interface Livro {
  titulo: string;
  autor: string;
}

@Injectable({
  providedIn: 'root'
})
export class BookService {

  private livros: Livro[] = [];
  private storageKey = 'biblioteca_batatinha';

  constructor() {
    this.carregar();
  }

  adicionar(livro: Livro) {
    this.livros.push(livro);
    this.salvar();
  }

  listar(): Livro[] {
    return this.livros;
  }

  private salvar() {
    localStorage.setItem(this.storageKey, JSON.stringify(this.livros));
  }

  private carregar() {
    const dados = localStorage.getItem(this.storageKey);
    if (dados) {
      this.livros = JSON.parse(dados);
    }
  }
}