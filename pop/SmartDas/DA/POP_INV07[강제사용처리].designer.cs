using SmartDas.Components;

namespace SmartDas
{
    partial class POP_INV07
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다.
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_INV07));
            this.label2 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.txtWRKORDNO = new System.Windows.Forms.TextBox();
            this.lblWRKORDNO = new System.Windows.Forms.Label();
            this.btn_PRD_END_DATE = new System.Windows.Forms.Button();
            this.btnPRD_DTR_DATE = new System.Windows.Forms.Button();
            this.dtpPRD_END_DATE = new System.Windows.Forms.DateTimePicker();
            this.dtpPRD_STR_DATE = new System.Windows.Forms.DateTimePicker();
            this.btnFind = new SmartDas.Components.MESButton();
            this.Grid1 = new SmartDas.Components.MESGrid();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.splitContainer1);
            // 
            // lblMessage
            // 
            this.lblMessage.Position = -36797;
            // 
            // btnRightPage
            // 
            this.btnRightPage.LinkGrid = this.Grid1;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkGrid = this.Grid1;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(448, 12);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(132, 50);
            this.label2.TabIndex = 49;
            this.label2.Text = "생산일자";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.label2.Visible = false;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.MidnightBlue;
            this.bBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 24F;
            this.bBox1.Location = new System.Drawing.Point(0, 0);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(1274, 81);
            this.bBox1.TabIndex = 64;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(1, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.txtWRKORDNO);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRKORDNO);
            this.splitContainer1.Panel1.Controls.Add(this.btn_PRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.btnPRD_DTR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.btnFind);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // txtWRKORDNO
            // 
            this.txtWRKORDNO.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWRKORDNO.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtWRKORDNO.Location = new System.Drawing.Point(162, 7);
            this.txtWRKORDNO.MinimumSize = new System.Drawing.Size(280, 50);
            this.txtWRKORDNO.Name = "txtWRKORDNO";
            this.txtWRKORDNO.Size = new System.Drawing.Size(280, 61);
            this.txtWRKORDNO.TabIndex = 182;
            // 
            // lblWRKORDNO
            // 
            this.lblWRKORDNO.BackColor = System.Drawing.Color.Gray;
            this.lblWRKORDNO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRKORDNO.ForeColor = System.Drawing.Color.White;
            this.lblWRKORDNO.Location = new System.Drawing.Point(7, 6);
            this.lblWRKORDNO.Name = "lblWRKORDNO";
            this.lblWRKORDNO.Size = new System.Drawing.Size(149, 50);
            this.lblWRKORDNO.TabIndex = 181;
            this.lblWRKORDNO.Text = "지시번호";
            this.lblWRKORDNO.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // btn_PRD_END_DATE
            // 
            this.btn_PRD_END_DATE.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.btn_PRD_END_DATE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btn_PRD_END_DATE.CausesValidation = false;
            this.btn_PRD_END_DATE.FlatAppearance.BorderSize = 0;
            this.btn_PRD_END_DATE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.btn_PRD_END_DATE.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btn_PRD_END_DATE.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btn_PRD_END_DATE.Location = new System.Drawing.Point(1041, 12);
            this.btn_PRD_END_DATE.Name = "btn_PRD_END_DATE";
            this.btn_PRD_END_DATE.Size = new System.Drawing.Size(46, 46);
            this.btn_PRD_END_DATE.TabIndex = 132;
            this.btn_PRD_END_DATE.Tag = "endDate";
            this.btn_PRD_END_DATE.UseVisualStyleBackColor = false;
            this.btn_PRD_END_DATE.Visible = false;
            this.btn_PRD_END_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // btnPRD_DTR_DATE
            // 
            this.btnPRD_DTR_DATE.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.btnPRD_DTR_DATE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnPRD_DTR_DATE.CausesValidation = false;
            this.btnPRD_DTR_DATE.FlatAppearance.BorderSize = 0;
            this.btnPRD_DTR_DATE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.btnPRD_DTR_DATE.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnPRD_DTR_DATE.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnPRD_DTR_DATE.Location = new System.Drawing.Point(785, 13);
            this.btnPRD_DTR_DATE.Name = "btnPRD_DTR_DATE";
            this.btnPRD_DTR_DATE.Size = new System.Drawing.Size(46, 46);
            this.btnPRD_DTR_DATE.TabIndex = 131;
            this.btnPRD_DTR_DATE.Tag = "startDate";
            this.btnPRD_DTR_DATE.UseVisualStyleBackColor = false;
            this.btnPRD_DTR_DATE.Visible = false;
            this.btnPRD_DTR_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // dtpPRD_END_DATE
            // 
            this.dtpPRD_END_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_END_DATE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_END_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_END_DATE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpPRD_END_DATE.Location = new System.Drawing.Point(845, 11);
            this.dtpPRD_END_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_END_DATE.Name = "dtpPRD_END_DATE";
            this.dtpPRD_END_DATE.ShowUpDown = true;
            this.dtpPRD_END_DATE.Size = new System.Drawing.Size(244, 55);
            this.dtpPRD_END_DATE.TabIndex = 127;
            this.dtpPRD_END_DATE.Visible = false;
            this.dtpPRD_END_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // dtpPRD_STR_DATE
            // 
            this.dtpPRD_STR_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_STR_DATE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_STR_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_STR_DATE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpPRD_STR_DATE.Location = new System.Drawing.Point(586, 11);
            this.dtpPRD_STR_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_STR_DATE.Name = "dtpPRD_STR_DATE";
            this.dtpPRD_STR_DATE.ShowUpDown = true;
            this.dtpPRD_STR_DATE.Size = new System.Drawing.Size(248, 55);
            this.dtpPRD_STR_DATE.TabIndex = 124;
            this.dtpPRD_STR_DATE.Visible = false;
            this.dtpPRD_STR_DATE.ValueChanged += new System.EventHandler(this.cboOrderDate_ValueChanged);
            this.dtpPRD_STR_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // btnFind
            // 
            this.btnFind.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnFind.BackColor = System.Drawing.Color.Transparent;
            this.btnFind.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnFind.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnFind.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnFind.ButtonPressed = false;
            this.btnFind.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnFind.DownPic = null;
            this.btnFind.ExTag = null;
            this.btnFind.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnFind.FontSize = 14F;
            this.btnFind.LinkButtonBox = null;
            this.btnFind.LinkDatePicker = null;
            this.btnFind.LinkGrid = null;
            this.btnFind.LinkMoveSize = 0;
            this.btnFind.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnFind.Location = new System.Drawing.Point(1106, 11);
            this.btnFind.Margin = new System.Windows.Forms.Padding(0);
            this.btnFind.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(154, 50);
            this.btnFind.TabIndex = 73;
            this.btnFind.Text = "조회";
            this.btnFind.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnFind.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnFind.UpPic = null;
            this.btnFind.UseFlag = true;
            this.btnFind.Click += new System.EventHandler(this.btnFind_Click);
            // 
            // Grid1
            // 
            this.Grid1.AutoScroll = true;
            this.Grid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid1.CountRows = 0;
            this.Grid1.DataSource = null;
            this.Grid1.FixedCols = 0;
            this.Grid1.FontSize = 20.25F;
            this.Grid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid1.HeaderFontSize = 13F;
            this.Grid1.HeadString = null;
            this.Grid1.Location = new System.Drawing.Point(10, 70);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 700);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // POP_INV07
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_INV07";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_INV07_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private MESButton btnFind;
        private System.Windows.Forms.DateTimePicker dtpPRD_STR_DATE;
        private System.Windows.Forms.DateTimePicker dtpPRD_END_DATE;
        private System.Windows.Forms.Button btnPRD_DTR_DATE;
        private System.Windows.Forms.Button btn_PRD_END_DATE;
        private System.Windows.Forms.TextBox txtWRKORDNO;
        private System.Windows.Forms.Label lblWRKORDNO;

    }
}
