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

  adicionar(livro: Livro) {
    this.livros.push(livro);
  }

  listar(): Livro[] {
    return this.livros;
  }
}