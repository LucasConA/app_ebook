import { Injectable } from '@angular/core';
import { Storage } from '@ionic/storage-angular';

@Injectable({
  providedIn: 'root'
})
export class BookService {

  private _storage: Storage | null = null;
  private STORAGE_KEY = 'books';

  constructor(private storage: Storage) {
    this.init();
  }

  async init() {
    const storage = await this.storage.create();
    this._storage = storage;
  }

  async getBooks() {
    return await this._storage?.get(this.STORAGE_KEY) || [];
  }

  async addBook(book: any) {
    const books = await this.getBooks();
    books.push(book);
    return this._storage?.set(this.STORAGE_KEY, books);
  }
}