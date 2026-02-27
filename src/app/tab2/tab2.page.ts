import { Component, OnInit } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { CommonModule } from '@angular/common';
import { BookService, Livro } from '../service/book';

@Component({
  selector: 'app-tab2',
  standalone: true,
  imports: [IonicModule, CommonModule],
  templateUrl: './tab2.page.html',
})
export class Tab2Page implements OnInit {

  livros: Livro[] = [];

  constructor(private bookService: BookService) {}

  ngOnInit() {
    this.livros = this.bookService.listar();
  }
}