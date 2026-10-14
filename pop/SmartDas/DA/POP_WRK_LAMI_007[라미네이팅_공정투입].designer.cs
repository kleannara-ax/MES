using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK_LAMI_007
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK_LAMI_007));
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblWrkOrdrSeqNo = new SmartDas.Components.MESLabel();
            this.lblWrkOrdrNo = new SmartDas.Components.MESLabel();
            this.lblLabel4 = new System.Windows.Forms.Label();
            this.btnFind = new SmartDas.Components.MESButton();
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.lblLotNo = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.lblQty = new SmartDas.Components.MESLabel();
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
            this.lblTitle.Font = new System.Drawing.Font("Malgun Gothic", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.splitContainer1);
            // 
            // lblMessage
            // 
            this.lblMessage.Position = -95417;
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
            this.bBox1.Font = new System.Drawing.Font("Malgun Gothic", 24F, System.Drawing.FontStyle.Bold);
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
            this.splitContainer1.Panel1.Controls.Add(this.lblQty);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.lblLotNo);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblWrkOrdrSeqNo);
            this.splitContainer1.Panel1.Controls.Add(this.lblWrkOrdrNo);
            this.splitContainer1.Panel1.Controls.Add(this.lblLabel4);
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
            // lblWrkOrdrSeqNo
            // 
            this.lblWrkOrdrSeqNo.BackColor = System.Drawing.Color.White;
            this.lblWrkOrdrSeqNo.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWrkOrdrSeqNo.ColorContent = System.Drawing.Color.Transparent;
            this.lblWrkOrdrSeqNo.ColorLabel = System.Drawing.Color.White;
            this.lblWrkOrdrSeqNo.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWrkOrdrSeqNo.Font = new System.Drawing.Font("Malgun Gothic", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWrkOrdrSeqNo.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWrkOrdrSeqNo.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWrkOrdrSeqNo.Location = new System.Drawing.Point(358, 12);
            this.lblWrkOrdrSeqNo.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWrkOrdrSeqNo.MoveControl = null;
            this.lblWrkOrdrSeqNo.Name = "lblWrkOrdrSeqNo";
            this.lblWrkOrdrSeqNo.Size = new System.Drawing.Size(39, 33);
            this.lblWrkOrdrSeqNo.TabIndex = 295;
            this.lblWrkOrdrSeqNo.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblWrkOrdrSeqNo.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWrkOrdrNo
            // 
            this.lblWrkOrdrNo.BackColor = System.Drawing.Color.White;
            this.lblWrkOrdrNo.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWrkOrdrNo.ColorContent = System.Drawing.Color.Transparent;
            this.lblWrkOrdrNo.ColorLabel = System.Drawing.Color.White;
            this.lblWrkOrdrNo.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWrkOrdrNo.Font = new System.Drawing.Font("Malgun Gothic", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWrkOrdrNo.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWrkOrdrNo.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWrkOrdrNo.Location = new System.Drawing.Point(135, 12);
            this.lblWrkOrdrNo.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWrkOrdrNo.MoveControl = null;
            this.lblWrkOrdrNo.Name = "lblWrkOrdrNo";
            this.lblWrkOrdrNo.Size = new System.Drawing.Size(222, 33);
            this.lblWrkOrdrNo.TabIndex = 294;
            this.lblWrkOrdrNo.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblWrkOrdrNo.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblLabel4
            // 
            this.lblLabel4.BackColor = System.Drawing.Color.Gray;
            this.lblLabel4.Font = new System.Drawing.Font("Malgun Gothic", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel4.ForeColor = System.Drawing.Color.White;
            this.lblLabel4.Location = new System.Drawing.Point(9, 12);
            this.lblLabel4.Name = "lblLabel4";
            this.lblLabel4.Size = new System.Drawing.Size(118, 32);
            this.lblLabel4.TabIndex = 293;
            this.lblLabel4.Text = "작업지시번호";
            this.lblLabel4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.btnFind.Font = new System.Drawing.Font("Malgun Gothic", 14F, System.Drawing.FontStyle.Bold);
            this.btnFind.FontSize = 14F;
            this.btnFind.LinkButtonBox = null;
            this.btnFind.LinkDatePicker = null;
            this.btnFind.LinkGrid = null;
            this.btnFind.LinkMoveSize = 0;
            this.btnFind.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnFind.Location = new System.Drawing.Point(1127, 12);
            this.btnFind.Margin = new System.Windows.Forms.Padding(0);
            this.btnFind.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(132, 33);
            this.btnFind.TabIndex = 125;
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
            this.Grid1.Location = new System.Drawing.Point(9, 53);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 719);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // lblLotNo
            // 
            this.lblLotNo.BackColor = System.Drawing.Color.White;
            this.lblLotNo.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblLotNo.ColorContent = System.Drawing.Color.Transparent;
            this.lblLotNo.ColorLabel = System.Drawing.Color.White;
            this.lblLotNo.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblLotNo.Font = new System.Drawing.Font("Malgun Gothic", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLotNo.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblLotNo.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblLotNo.Location = new System.Drawing.Point(531, 12);
            this.lblLotNo.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblLotNo.MoveControl = null;
            this.lblLotNo.Name = "lblLotNo";
            this.lblLotNo.Size = new System.Drawing.Size(222, 33);
            this.lblLotNo.TabIndex = 297;
            this.lblLotNo.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblLotNo.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("Malgun Gothic", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(405, 12);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(118, 32);
            this.label1.TabIndex = 296;
            this.label1.Text = "LOT.NO";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("Malgun Gothic", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(761, 12);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(118, 32);
            this.label2.TabIndex = 298;
            this.label2.Text = "투입지시량";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblQty
            // 
            this.lblQty.BackColor = System.Drawing.Color.White;
            this.lblQty.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblQty.ColorContent = System.Drawing.Color.Transparent;
            this.lblQty.ColorLabel = System.Drawing.Color.White;
            this.lblQty.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblQty.Font = new System.Drawing.Font("Malgun Gothic", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblQty.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblQty.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblQty.Location = new System.Drawing.Point(887, 12);
            this.lblQty.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblQty.MoveControl = null;
            this.lblQty.Name = "lblQty";
            this.lblQty.Size = new System.Drawing.Size(109, 33);
            this.lblQty.TabIndex = 299;
            this.lblQty.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblQty.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK_LAMI_007
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK_LAMI_007";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK_LAMI_007_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
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
        private MESLabel lblWrkOrdrSeqNo;
        private MESLabel lblWrkOrdrNo;
        private System.Windows.Forms.Label lblLabel4;
        private MESLabel lblLotNo;
        private System.Windows.Forms.Label label1;
        private MESLabel lblQty;
        private System.Windows.Forms.Label label2;

    }
}
