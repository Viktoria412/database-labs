#include "mainwindow.h"

// ============================================================
// Приложение «Парикмахерская» (Qt / C++)
// ЛР №6 — Технологии доступа к базам данных
// ============================================================

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    initializeUI();
    initDatabase();
}

MainWindow::~MainWindow()
{
    if (db.isOpen()) db.close();
}

bool MainWindow::initDatabase()
{
    db = QSqlDatabase::addDatabase("QPSQL");
    db.setHostName("localhost");
    db.setDatabaseName("postgres");
    db.setUserName("postgres");
    db.setPassword("postgres");   // <-- замените на свой пароль
    db.setPort(5432);
    return db.open();
}

void MainWindow::initializeUI()
{
    setWindowTitle("Парикмахерская (Qt)");
    resize(900, 650);

    QWidget     *central    = new QWidget(this);
    setCentralWidget(central);
    QVBoxLayout *mainLayout = new QVBoxLayout(central);
    QHBoxLayout *btnLayout  = new QHBoxLayout();

    btnConnect = new QPushButton("Подключить", this);
    connect(btnConnect, &QPushButton::clicked, this, &MainWindow::connectToDatabase);
    btnLayout->addWidget(btnConnect);

    btnTables = new QPushButton("Таблицы", this);
    connect(btnTables, &QPushButton::clicked, this, &MainWindow::showTablesMenu);
    btnLayout->addWidget(btnTables);

    btnSearch = new QPushButton("Поиск", this);
    connect(btnSearch, &QPushButton::clicked, this, &MainWindow::showSearchMenu);
    btnLayout->addWidget(btnSearch);

    btnAddMaster = new QPushButton("Добавить мастера", this);
    connect(btnAddMaster, &QPushButton::clicked, this, &MainWindow::addMaster);
    btnLayout->addWidget(btnAddMaster);

    btnDeleteVisit = new QPushButton("Удалить визит", this);
    connect(btnDeleteVisit, &QPushButton::clicked, this, &MainWindow::deleteVisit);
    btnLayout->addWidget(btnDeleteVisit);

    btnLayout->addStretch();
    mainLayout->addLayout(btnLayout);

    tableWidget = new QTableWidget(this);
    tableWidget->setAlternatingRowColors(true);
    tableWidget->setEditTriggers(QAbstractItemView::NoEditTriggers);
    mainLayout->addWidget(tableWidget);
}

void MainWindow::connectToDatabase()
{
    if (db.isOpen()) {
        QMessageBox::information(this, "Информация", "Уже подключено к базе данных");
        return;
    }
    if (initDatabase())
        QMessageBox::information(this, "Успех", "Подключение успешно!");
    else
        QMessageBox::critical(this, "Ошибка", "Ошибка подключения: " + db.lastError().text());
}

void MainWindow::showTablesMenu()
{
    if (!db.isOpen()) { QMessageBox::warning(this, "Внимание", "Сначала подключитесь к БД"); return; }
    QMenu menu(this);
    menu.addAction("Клиенты", [this]() { loadTable("public.\"Klienty\""); });
    menu.addAction("Мастера",  [this]() { loadTable("public.\"Mastera\""); });
    menu.addAction("Услуги",   [this]() { loadTable("public.\"Uslugi\""); });
    menu.addAction("Визиты",   [this]() { loadTable("public.\"Vizity\""); });
    menu.exec(btnTables->mapToGlobal(QPoint(0, btnTables->height())));
}

void MainWindow::loadTable(const QString &tableName)
{
    QSqlQuery query;
    if (query.exec("SELECT * FROM " + tableName))
        fillTableFromQuery(query);
    else
        QMessageBox::critical(this, "Ошибка", "Не удалось загрузить таблицу:\n" + query.lastError().text());
}

void MainWindow::showSearchMenu()
{
    if (!db.isOpen()) { QMessageBox::warning(this, "Внимание", "Сначала подключитесь к БД"); return; }
    QMenu menu(this);
    menu.addAction("Поиск клиента по фамилии",  [this]() { searchClientBySurname(); });
    menu.addAction("Поиск услуг по стоимости",  [this]() { searchServicesByPrice(); });
    menu.exec(btnSearch->mapToGlobal(QPoint(0, btnSearch->height())));
}

void MainWindow::searchClientBySurname()
{
    bool ok;
    QString surname = QInputDialog::getText(this, "Поиск клиента", "Введите фамилию:", QLineEdit::Normal, "", &ok);
    if (!ok || surname.isEmpty()) return;

    QSqlQuery query;
    query.prepare("SELECT * FROM public.\"Klienty\" WHERE \"Familya\" = :fam");
    query.bindValue(":fam", surname.trimmed());
    if (query.exec())
        fillTableFromQuery(query);
    else
        QMessageBox::critical(this, "Ошибка", query.lastError().text());
}

void MainWindow::searchServicesByPrice()
{
    bool ok;
    double price = QInputDialog::getDouble(this, "Поиск услуг", "Максимальная стоимость:", 0, 0, 100000, 0, &ok);
    if (!ok) return;

    QSqlQuery query;
    query.prepare("SELECT * FROM public.\"Uslugi\" WHERE \"Stoimost\" <= :price");
    query.bindValue(":price", price);
    if (query.exec())
        fillTableFromQuery(query);
    else
        QMessageBox::critical(this, "Ошибка", query.lastError().text());
}

void MainWindow::addMaster()
{
    QDialog dialog(this);
    dialog.setWindowTitle("Добавление мастера");
    dialog.resize(350, 280);
    QFormLayout *form = new QFormLayout(&dialog);

    QLineEdit *edId    = new QLineEdit;
    QLineEdit *edFam   = new QLineEdit;
    QLineEdit *edImya  = new QLineEdit;
    QLineEdit *edOtch  = new QLineEdit;
    QLineEdit *edSpec  = new QLineEdit;

    form->addRow("ID мастера:",      edId);
    form->addRow("Фамилия:",         edFam);
    form->addRow("Имя:",             edImya);
    form->addRow("Отчество:",        edOtch);
    form->addRow("Специализация:",   edSpec);

    QHBoxLayout *btnRow = new QHBoxLayout;
    QPushButton *btnOk     = new QPushButton("Добавить");
    QPushButton *btnCancel = new QPushButton("Отмена");
    btnRow->addWidget(btnOk);
    btnRow->addWidget(btnCancel);
    form->addRow(btnRow);

    connect(btnOk,     &QPushButton::clicked, &dialog, &QDialog::accept);
    connect(btnCancel, &QPushButton::clicked, &dialog, &QDialog::reject);

    if (dialog.exec() == QDialog::Accepted) {
        QSqlQuery query;
        query.prepare("INSERT INTO public.\"Mastera\" (\"ID_mastera\",\"Familya\",\"Imya\",\"Otchestvo\",\"Spetsializatsiya\") "
                      "VALUES (:id,:fam,:imya,:otch,:spec)");
        query.bindValue(":id",   edId->text().toInt());
        query.bindValue(":fam",  edFam->text());
        query.bindValue(":imya", edImya->text());
        query.bindValue(":otch", edOtch->text());
        query.bindValue(":spec", edSpec->text());
        if (query.exec())
            QMessageBox::information(this, "Успех", "Мастер успешно добавлен!");
        else
            QMessageBox::critical(this, "Ошибка", query.lastError().text());
    }
}

void MainWindow::deleteVisit()
{
    bool ok;
    int id = QInputDialog::getInt(this, "Удаление визита", "Введите ID визита:", 1, 1, 999999, 1, &ok);
    if (!ok) return;

    QSqlQuery query;
    query.prepare("DELETE FROM public.\"Vizity\" WHERE \"ID_vizita\" = :id");
    query.bindValue(":id", id);
    if (query.exec() && query.numRowsAffected() > 0)
        QMessageBox::information(this, "Успех", "Визит удалён!");
    else
        QMessageBox::warning(this, "Не найден", "Визит с таким ID не найден.\n" + query.lastError().text());
}

void MainWindow::fillTableFromQuery(QSqlQuery &query)
{
    QSqlRecord record = query.record();
    int colCount = record.count();
    tableWidget->clear();
    tableWidget->setColumnCount(colCount);

    QStringList headers;
    for (int i = 0; i < colCount; ++i)
        headers << record.fieldName(i);
    tableWidget->setHorizontalHeaderLabels(headers);

    tableWidget->setRowCount(0);
    while (query.next()) {
        int row = tableWidget->rowCount();
        tableWidget->insertRow(row);
        for (int col = 0; col < colCount; ++col)
            tableWidget->setItem(row, col, new QTableWidgetItem(query.value(col).toString()));
    }
    tableWidget->resizeColumnsToContents();
}
