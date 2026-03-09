import { Component, OnInit } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { BookService, Livro } from '../service/book';
import { ToastController } from '@ionic/angular';

@Component({
  selector: 'app-tab1',
  standalone: true,
  imports: [IonicModule, FormsModule, CommonModule],
  templateUrl: './tab1.page.html',
})
export class Tab1Page implements OnInit {

  titulo = '';
  autor = '';
  idioma = '';
  genero = '';
  tags = '';
  link = '';

  capaUrl = '';
  capaPreview: string | null = null;

  livros: Livro[] = [];

  isDragging = false;

  constructor(
  private bookService: BookService,
  private toastController: ToastController
) {}

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
      capa: this.capaPreview || '',
      criadoEm: new Date()
    });

    await this.mostrarToast('Livro adicionado à biblioteca');
    this.livros = await this.bookService.listar();

    this.titulo = '';
    this.autor = '';
    this.idioma = '';
    this.genero = '';
    this.tags = '';
    this.link = '';
    this.capaPreview = null;
    this.capaUrl = '';
  }

  onDragOver(event: DragEvent) {
  event.preventDefault();
  event.stopPropagation();
}

onDragEnter(event: DragEvent) {
  event.preventDefault();
  event.stopPropagation();
  this.isDragging = true;
}

onDragLeave(event: DragEvent) {
  event.preventDefault();
  event.stopPropagation();
  this.isDragging = false;
}

onDrop(event: DragEvent) {

  event.preventDefault();
  event.stopPropagation();

  this.isDragging = false;

  const file = event.dataTransfer?.files?.[0];

  if (!file) return;

  if (!file.type.startsWith('image/')) {
    alert('Por favor arraste apenas imagens.');
    return;
  }

  this.lerArquivo(file);
}

  onFileSelected(event: any) {

    const file = event.target.files[0];

    if (file) {
      this.lerArquivo(file);
    }

  }

  lerArquivo(file: File) {

    const reader = new FileReader();

    reader.onload = () => {
      this.capaPreview = reader.result as string;
    };

    reader.readAsDataURL(file);

  }

  async usarUrl() {

  if (!this.capaUrl) return;

  this.capaPreview = this.capaUrl.trim();

  await this.mostrarToast('Capa carregada pela URL');

}
  async mostrarToast(mensagem: string) {

  const toast = await this.toastController.create({
    message: mensagem,
    duration: 2000,
    position: 'middle',
    icon: 'checkmark-circle-outline',
    color: 'primary'
  });

  await toast.present();

}
  
}