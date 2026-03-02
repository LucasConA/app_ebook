import { Injectable } from '@angular/core';
import { Storage } from '@ionic/storage-angular';

export interface Livro {
  id: string;
  titulo: string;
  autor: string;
  idioma: string;
  genero: string;
  capa?: string;     // base64 da imagem
  tags: string[];
  link?: string;
  criadoEm: Date;
}

@Injectable({
  providedIn: 'root'
})
export class BookService {

  private _storage!: Storage;
  private storageKey = 'biblioteca_batatinha';
  private _initPromise: Promise<void>;

  constructor(private storage: Storage) {
    this._initPromise = this.init();
  }

  async init() {
    this._storage = await this.storage.create();
  }

  async adicionar(livro: Livro) {
    await this._initPromise;

    const livros = await this.listar();
    livros.push(livro);
    await this._storage.set(this.storageKey, livros);
  }

  async listar(): Promise<Livro[]> {
    await this._initPromise;

    return (await this._storage.get(this.storageKey)) || [];
  }

  async remover(id: string) {
  const livros = await this.listar();
  const novosLivros = livros.filter(l => l.id !== id);
  await this._storage.set(this.storageKey, novosLivros);
}

  async atualizar(livro: Livro) {
    // lógica para atualizar no storage
  }
}