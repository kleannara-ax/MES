using SmartDas.Components;

namespace SmartDas
{
    partial class POP_INV05
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_INV05));
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblMATNR = new SmartDas.Components.MESLabel();
            this.btnMATNR = new SmartDas.Components.MESLabel();
            this.txtINDBCD = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.txtMATNR = new System.Windows.Forms.TextBox();
            this.btnLOCATION = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.lblSTOR_LOC = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
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
            this.lblMessage.Position = 83;
            // 
            // btnRightPage
            // 
            this.btnRightPage.LinkGrid = this.Grid1;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkGrid = this.Grid1;
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
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.btnMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.txtINDBCD);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.txtMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.btnLOCATION);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.lblSTOR_LOC);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.btnFind);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblMATNR
            // 
            this.lblMATNR.BackColor = System.Drawing.Color.White;
            this.lblMATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR.ColorLabel = System.Drawing.Color.White;
            this.lblMATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR.Location = new System.Drawing.Point(475, 11);
            this.lblMATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR.MoveControl = null;
            this.lblMATNR.Name = "lblMATNR";
            this.lblMATNR.Size = new System.Drawing.Size(338, 50);
            this.lblMATNR.TabIndex = 186;
            this.lblMATNR.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblMATNR.Click += new System.EventHandler(this.lblMATNR_Click);
            // 
            // btnMATNR
            // 
            this.btnMATNR.BackColor = System.Drawing.Color.DeepSkyBlue;
            this.btnMATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnMATNR.BackgroundImage = global::SmartDas.Properties.Resources.버튼10;
            this.btnMATNR.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnMATNR.ColorContent = System.Drawing.Color.Transparent;
            this.btnMATNR.ColorLabel = System.Drawing.Color.DeepSkyBlue;
            this.btnMATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.btnMATNR.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnMATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.btnMATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.btnMATNR.Location = new System.Drawing.Point(812, 11);
            this.btnMATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.btnMATNR.MoveControl = null;
            this.btnMATNR.Name = "btnMATNR";
            this.btnMATNR.Size = new System.Drawing.Size(49, 50);
            this.btnMATNR.TabIndex = 185;
            this.btnMATNR.Text = "▼";
            this.btnMATNR.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnMATNR.Click += new System.EventHandler(this.lblMATNR_Click);
            // 
            // txtINDBCD
            // 
            this.txtINDBCD.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtINDBCD.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtINDBCD.Location = new System.Drawing.Point(948, 11);
            this.txtINDBCD.MinimumSize = new System.Drawing.Size(230, 50);
            this.txtINDBCD.Name = "txtINDBCD";
            this.txtINDBCD.Size = new System.Drawing.Size(230, 61);
            this.txtINDBCD.TabIndex = 184;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(864, 11);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(83, 50);
            this.label3.TabIndex = 183;
            this.label3.Text = "바코드";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtMATNR
            // 
            this.txtMATNR.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtMATNR.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtMATNR.Location = new System.Drawing.Point(483, 11);
            this.txtMATNR.MinimumSize = new System.Drawing.Size(280, 50);
            this.txtMATNR.Name = "txtMATNR";
            this.txtMATNR.Size = new System.Drawing.Size(378, 61);
            this.txtMATNR.TabIndex = 182;
            // 
            // btnLOCATION
            // 
            this.btnLOCATION.BackColor = System.Drawing.Color.DeepSkyBlue;
            this.btnLOCATION.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnLOCATION.BackgroundImage = global::SmartDas.Properties.Resources.버튼10;
            this.btnLOCATION.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLOCATION.ColorContent = System.Drawing.Color.Transparent;
            this.btnLOCATION.ColorLabel = System.Drawing.Color.DeepSkyBlue;
            this.btnLOCATION.ColorReadOnly = System.Drawing.Color.Transparent;
            this.btnLOCATION.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnLOCATION.LabelPadding = new System.Drawing.Size(0, 0);
            this.btnLOCATION.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.btnLOCATION.Location = new System.Drawing.Point(320, 11);
            this.btnLOCATION.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.btnLOCATION.MoveControl = null;
            this.btnLOCATION.Name = "btnLOCATION";
            this.btnLOCATION.Size = new System.Drawing.Size(49, 50);
            this.btnLOCATION.TabIndex = 125;
            this.btnLOCATION.Text = "▼";
            this.btnLOCATION.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnLOCATION.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnLOCATION.Click += new System.EventHandler(this.lblSTOR_LOC_Click);
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(372, 11);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(106, 50);
            this.label2.TabIndex = 181;
            this.label2.Text = "자재코드";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblSTOR_LOC
            // 
            this.lblSTOR_LOC.BackColor = System.Drawing.Color.White;
            this.lblSTOR_LOC.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblSTOR_LOC.ColorContent = System.Drawing.Color.Transparent;
            this.lblSTOR_LOC.ColorLabel = System.Drawing.Color.White;
            this.lblSTOR_LOC.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblSTOR_LOC.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblSTOR_LOC.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblSTOR_LOC.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblSTOR_LOC.Location = new System.Drawing.Point(100, 11);
            this.lblSTOR_LOC.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblSTOR_LOC.MoveControl = null;
            this.lblSTOR_LOC.Name = "lblSTOR_LOC";
            this.lblSTOR_LOC.Size = new System.Drawing.Size(223, 50);
            this.lblSTOR_LOC.TabIndex = 126;
            this.lblSTOR_LOC.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblSTOR_LOC.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblSTOR_LOC.Click += new System.EventHandler(this.lblSTOR_LOC_Click);
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(9, 11);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(91, 50);
            this.label1.TabIndex = 124;
            this.label1.Text = "저장위치";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.btnFind.Location = new System.Drawing.Point(1186, 11);
            this.btnFind.Margin = new System.Windows.Forms.Padding(0);
            this.btnFind.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(74, 50);
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
            this.Grid1.Location = new System.Drawing.Point(9, 67);
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
            // POP_INV05
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_INV05";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_INV05_Load);
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

        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private MESButton btnFind;
        private MESLabel btnLOCATION;
        private MESLabel lblSTOR_LOC;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtMATNR;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox txtINDBCD;
        private MESLabel btnMATNR;
        private MESLabel lblMATNR;
    }
}
