import { Component } from '@angular/core';
import { IonicModule } from '@ionic/angular';
import { CommonModule } from '@angular/common';
import { BookService, Livro } from '../service/book';
import { ModalController } from '@ionic/angular';
import { LivroDetalheComponent } from '../livro-detalhe/livro-detalhe.component';
import { addIcons } from 'ionicons';
import { trash } from 'ionicons/icons';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-tab2',
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule],
  templateUrl: './tab2.page.html',
  styleUrls: ['./tab2.page.scss'],
})
export class Tab2Page {

  livros: Livro[] = [];
  ordemSelecionada: string = 'recente';

  constructor(
    private bookService: BookService,
    private modalCtrl: ModalController
  ) {addIcons({trash})}
  
  

  async ionViewWillEnter() {
    this.livros = await this.bookService.listar();
     this.ordenarLivros();
  }

  async removerLivro(id: string) {
    await this.bookService.remover(id);
    this.livros = await this.bookService.listar();
  }

  async abrirDetalhes(livro: Livro) {
    const modal = await this.modalCtrl.create({
      component: LivroDetalheComponent,
      componentProps: { livro }
    });

    await modal.present();

    const { data } = await modal.onWillDismiss();

    if (data?.atualizado) {
      this.livros = await this.bookService.listar();
    }
  }

ordenarLivros() {

  switch (this.ordemSelecionada) {

    case 'recente':
      this.livros.sort((a, b) =>
        new Date(b.criadoEm).getTime() -
        new Date(a.criadoEm).getTime()
      );
      break;

    case 'antigo':
      this.livros.sort((a, b) =>
        new Date(a.criadoEm).getTime() -
        new Date(b.criadoEm).getTime()
      );
      break;

    case 'titulo_az':
      this.livros.sort((a, b) =>
        a.titulo.localeCompare(b.titulo)
      );
      break;

    case 'titulo_za':
      this.livros.sort((a, b) =>
        b.titulo.localeCompare(a.titulo)
      );
      break;

  }

}
}

