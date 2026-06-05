using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using Npgsql;
using Label = System.Windows.Forms.Label;

namespace BarbershopApp
{
    /// <summary>
    /// Главная форма приложения для работы с БД «Парикмахерская».
    /// ЛР №6 — Технологии доступа к базам данных.
    /// </summary>
    public partial class Form1 : Form
    {
        private DataGridView dgv;
        private Button btnTables;
        private Button btnQuery;
        private Button btnConnect;
        private Button btnAddMaster;
        private Button btnDeleteVisit;
        private NpgsqlConnection conn;
        private TextBox txtSearch;

        public Form1()
        {
            InitializeUI();
            conn = DBUtils.GetDBConnection();
        }

        private void InitializeUI()
        {
            this.Text = "Парикмахерская";
            this.Size = new Size(900, 650);

            var panel = new Panel();
            panel.Dock = DockStyle.Top;
            panel.Height = 40;
            panel.BackColor = System.Drawing.Color.LightGray;

            btnConnect = new Button { Text = "Подключить", Location = new Point(10, 5), Size = new Size(90, 30) };
            btnConnect.Click += btnConnect_Click;
            panel.Controls.Add(btnConnect);

            btnTables = new Button { Text = "Таблицы", Location = new Point(110, 5), Size = new Size(80, 30) };
            btnTables.Click += TablesButton_Click;
            panel.Controls.Add(btnTables);

            btnQuery = new Button { Text = "Поиск", Location = new Point(200, 5), Size = new Size(80, 30) };
            btnQuery.Click += zapros_Click;
            panel.Controls.Add(btnQuery);

            btnAddMaster = new Button { Text = "Добавить мастера", Location = new Point(290, 5), Size = new Size(120, 30) };
            btnAddMaster.Click += btnAddMaster_Click;
            panel.Controls.Add(btnAddMaster);

            btnDeleteVisit = new Button { Text = "Удалить визит", Location = new Point(420, 5), Size = new Size(100, 30) };
            btnDeleteVisit.Click += btnDeleteVisit_Click;
            panel.Controls.Add(btnDeleteVisit);

            this.Controls.Add(panel);

            dgv = new DataGridView
            {
                Top = panel.Bottom + 10,
                Left = 0,
                Width = this.ClientSize.Width,
                Height = this.ClientSize.Height - panel.Bottom - 40,
                Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right,
                ReadOnly = true
            };
            this.Controls.Add(dgv);

            txtSearch = new TextBox { Location = new Point(20, 55), Width = 200 };
            this.Controls.Add(txtSearch);
        }

        private void btnConnect_Click(object sender, EventArgs e)
        {
            try
            {
                conn.Open();
                MessageBox.Show("Подключение успешно!");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка подключения: {ex.Message}");
            }
        }

        private void TablesButton_Click(object sender, EventArgs e)
        {
            var menu = new ContextMenuStrip();
            menu.Items.Add("Клиенты", null, (s, args) => LoadTable("public.\"Klienty\""));
            menu.Items.Add("Мастера",  null, (s, args) => LoadTable("public.\"Mastera\""));
            menu.Items.Add("Услуги",   null, (s, args) => LoadTable("public.\"Uslugi\""));
            menu.Items.Add("Визиты",   null, (s, args) => LoadTable("public.\"Vizity\""));
            menu.Show(btnTables, new Point(0, btnTables.Height));
        }

        private void LoadTable(string tableName)
        {
            try
            {
                string script = $"SELECT * FROM {tableName}";
                using (var adapter = new NpgsqlDataAdapter(script, conn))
                {
                    DataTable table = new DataTable();
                    adapter.Fill(table);
                    dgv.DataSource = table;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка загрузки таблицы {tableName}:\n{ex.Message}");
            }
        }

        private void zapros_Click(object sender, EventArgs e)
        {
            var menu = new ContextMenuStrip();
            menu.Items.Add("Поиск клиента по фамилии",   null, (s, args) => SearchClientBySurname());
            menu.Items.Add("Поиск услуг по стоимости",   null, (s, args) => SearchServicesByPrice());
            menu.Show(btnQuery, new Point(0, btnQuery.Height));
        }

        private void SearchClientBySurname()
        {
            using (var inputDialog = new InputDialog("Введите фамилию клиента:"))
            {
                if (inputDialog.ShowDialog() == DialogResult.OK)
                {
                    try
                    {
                        if (conn.State != ConnectionState.Open) conn.Open();
                        string sql = @"SELECT * FROM public.""Klienty"" WHERE ""Familya"" = @fam";
                        using (var cmd = new NpgsqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@fam", inputDialog.Value.Trim());
                            using (var adapter = new NpgsqlDataAdapter(cmd))
                            {
                                DataTable table = new DataTable();
                                adapter.Fill(table);
                                dgv.DataSource = table;
                                if (table.Rows.Count == 0)
                                    MessageBox.Show("Клиенты не найдены");
                            }
                        }
                    }
                    catch (Exception ex) { MessageBox.Show($"Ошибка запроса:\n{ex.Message}"); }
                }
            }
        }

        private void SearchServicesByPrice()
        {
            using (var inputDialog = new InputDialog("Введите максимальную стоимость:"))
            {
                if (inputDialog.ShowDialog() == DialogResult.OK)
                {
                    try
                    {
                        if (conn.State != ConnectionState.Open) conn.Open();
                        string sql = @"SELECT * FROM public.""Uslugi"" WHERE ""Stoimost"" <= @price";
                        using (var cmd = new NpgsqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@price", decimal.Parse(inputDialog.Value.Trim()));
                            using (var adapter = new NpgsqlDataAdapter(cmd))
                            {
                                DataTable table = new DataTable();
                                adapter.Fill(table);
                                dgv.DataSource = table;
                                if (table.Rows.Count == 0)
                                    MessageBox.Show("Услуги не найдены");
                            }
                        }
                    }
                    catch (Exception ex) { MessageBox.Show($"Ошибка поиска:\n{ex.Message}"); }
                }
            }
        }

        private void btnAddMaster_Click(object sender, EventArgs e)
        {
            Form inputForm = new Form
            {
                Text = "Добавление мастера", Width = 350, Height = 320,
                StartPosition = FormStartPosition.CenterParent
            };
            var txtFamilya        = new TextBox { Top = 20,  Left = 130, Width = 180 };
            var txtImya           = new TextBox { Top = 50,  Left = 130, Width = 180 };
            var txtOtchestvo      = new TextBox { Top = 80,  Left = 130, Width = 180 };
            var txtSpecialization = new TextBox { Top = 110, Left = 130, Width = 180 };
            var txtMasterId       = new TextBox { Top = 140, Left = 130, Width = 180 };
            var btnOk     = new Button { Text = "Добавить", DialogResult = DialogResult.OK,     Top = 180, Left = 130, Width = 80 };
            var btnCancel = new Button { Text = "Отмена",   DialogResult = DialogResult.Cancel, Top = 180, Left = 220, Width = 80 };

            inputForm.Controls.AddRange(new Control[] {
                new Label { Text = "Фамилия:",         Top = 20,  Left = 20, Width = 100 }, txtFamilya,
                new Label { Text = "Имя:",             Top = 50,  Left = 20, Width = 100 }, txtImya,
                new Label { Text = "Отчество:",        Top = 80,  Left = 20, Width = 100 }, txtOtchestvo,
                new Label { Text = "Специализация:",   Top = 110, Left = 20, Width = 100 }, txtSpecialization,
                new Label { Text = "ID мастера:",      Top = 140, Left = 20, Width = 100 }, txtMasterId,
                btnOk, btnCancel
            });
            inputForm.AcceptButton = btnOk;
            inputForm.CancelButton = btnCancel;

            if (inputForm.ShowDialog() == DialogResult.OK)
            {
                try
                {
                    if (conn.State != ConnectionState.Open) conn.Open();
                    using (var cmd = new NpgsqlCommand(
                        "INSERT INTO public.\"Mastera\" (\"ID_mastera\",\"Familya\",\"Imya\",\"Otchestvo\",\"Spetsializatsiya\") " +
                        "VALUES (@id,@fam,@imya,@otch,@spec)", conn))
                    {
                        cmd.Parameters.AddWithValue("@id",   int.Parse(txtMasterId.Text));
                        cmd.Parameters.AddWithValue("@fam",  txtFamilya.Text);
                        cmd.Parameters.AddWithValue("@imya", txtImya.Text);
                        cmd.Parameters.AddWithValue("@otch", txtOtchestvo.Text);
                        cmd.Parameters.AddWithValue("@spec", txtSpecialization.Text);
                        cmd.ExecuteNonQuery();
                        MessageBox.Show("Мастер успешно добавлен!");
                        LoadTable("public.\"Mastera\"");
                    }
                }
                catch (Npgsql.PostgresException ex) { MessageBox.Show($"Ошибка выполнения:\n{ex.MessageText}"); }
                catch (Exception ex)                { MessageBox.Show($"Ошибка:\n{ex.Message}"); }
            }
        }

        private void btnDeleteVisit_Click(object sender, EventArgs e)
        {
            using (var inputDialog = new InputDialog("Введите ID визита для удаления:"))
            {
                if (inputDialog.ShowDialog() == DialogResult.OK)
                {
                    try
                    {
                        if (conn.State != ConnectionState.Open) conn.Open();
                        string sql = @"DELETE FROM public.""Vizity"" WHERE ""ID_vizita"" = @id";
                        using (var cmd = new NpgsqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@id", int.Parse(inputDialog.Value.Trim()));
                            int rows = cmd.ExecuteNonQuery();
                            if (rows > 0) { MessageBox.Show("Визит успешно удалён!"); LoadTable("public.\"Vizity\""); }
                            else MessageBox.Show("Визит с указанным ID не найден");
                        }
                    }
                    catch (Npgsql.PostgresException ex) when (ex.SqlState == "P0001")
                        { MessageBox.Show($"Ошибка удаления: {ex.Message}"); }
                    catch (Exception ex)
                        { MessageBox.Show($"Ошибка: {ex.Message}"); }
                }
            }
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (conn != null && conn.State == ConnectionState.Open) conn.Close();
        }
    }
}
