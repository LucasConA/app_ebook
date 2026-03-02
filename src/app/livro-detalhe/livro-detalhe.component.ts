import { Component, Input, OnInit } from '@angular/core';
import { IonicModule, ModalController } from '@ionic/angular';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BookService, Livro } from '../service/book';

@Component({
  selector: 'app-livro-detalhe',
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule],
  templateUrl: './livro-detalhe.component.html',
})
export class LivroDetalheComponent implements OnInit {

  @Input() livro!: Livro;

  modoEdicao = false;
  livroEditando!: Livro;

  // ✅ Campo auxiliar para edição das tags
  tagsInput: string = '';

  constructor(
    private modalCtrl: ModalController,
    private bookService: BookService
  ) {}

  ngOnInit() {
    this.livroEditando = { ...this.livro };

    // Converte array para string para edição
    this.tagsInput = this.livro.tags?.join(', ') || '';
  }

  ativarEdicao() {
    this.modoEdicao = true;
  }

  cancelarEdicao() {
    this.livroEditando = { ...this.livro };
    this.tagsInput = this.livro.tags?.join(', ') || '';
    this.modoEdicao = false;
  }

  async salvar() {

    // Converte string novamente para array
    this.livroEditando.tags = this.tagsInput
      .split(',')
      .map(t => t.trim())
      .filter(t => t.length > 0);

    await this.bookService.atualizar(this.livroEditando);

    this.modalCtrl.dismiss({ atualizado: true });
  }

  dismiss() {
    this.modalCtrl.dismiss();
  }
}