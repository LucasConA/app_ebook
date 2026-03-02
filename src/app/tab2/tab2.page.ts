import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { CommonModule } from '@angular/common';
import { BookService, Livro } from '../service/book';
import { ModalController } from '@ionic/angular';
import { LivroDetalheComponent } from '../livro-detalhe/livro-detalhe.component';
import { addIcons } from 'ionicons';
import { trash } from 'ionicons/icons';


@Component({
  selector: 'app-tab2',
  standalone: true,
  imports: [IonicModule, CommonModule],
  templateUrl: './tab2.page.html',
})
export class Tab2Page {

  livros: Livro[] = [];
  isModalOpen: boolean = false;
  constructor(
  private bookService: BookService,
  private modalCtrl: ModalController
) {
  addIcons({ trash });
}

  async ionViewWillEnter() {
    this.livros = await this.bookService.listar();
  }

  async removerLivro(id: string) {
  await this.bookService.remover(id);
  this.livros = await this.bookService.listar();
}

async abrirDetalhes(livro: Livro) {
  const modal = await this.modalCtrl.create({
    component: LivroDetalheComponent,
    componentProps: {
      livro: livro
    }
  });

  await modal.present();

  const { data } = await modal.onWillDismiss();

  if (data?.atualizado) {
    this.livros = await this.bookService.listar();
  }
}
}


