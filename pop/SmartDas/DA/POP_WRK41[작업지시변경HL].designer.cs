using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK41
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
            this.label2 = new System.Windows.Forms.Label();
            this.lblItemCode = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.lblPaperWidth = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblDispoQty = new SmartDas.Components.MESLabel();
            this.lblProdQty = new SmartDas.Components.MESLabel();
            this.lblTotalQty = new SmartDas.Components.MESLabel();
            this.lblDispoHead = new System.Windows.Forms.Label();
            this.lblProdHead = new System.Windows.Forms.Label();
            this.lblTotalHead = new System.Windows.Forms.Label();
            this.butStartDateN = new System.Windows.Forms.Button();
            this.butEndDate = new System.Windows.Forms.Button();
            this.butStartDate = new System.Windows.Forms.Button();
            this.dtpStartDateN = new System.Windows.Forms.DateTimePicker();
            this.lblStartTimeN = new SmartDas.Components.MESLabel();
            this.label25 = new System.Windows.Forms.Label();
            this.dtpEndDate = new System.Windows.Forms.DateTimePicker();
            this.dtpStartDate = new System.Windows.Forms.DateTimePicker();
            this.lblEndTime = new SmartDas.Components.MESLabel();
            this.label24 = new System.Windows.Forms.Label();
            this.lblStartTime = new SmartDas.Components.MESLabel();
            this.label23 = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.lblOrderRemarkN = new SmartDas.Components.MESLabel();
            this.label10 = new System.Windows.Forms.Label();
            this.lblOrderNoN = new SmartDas.Components.MESLabel();
            this.label11 = new System.Windows.Forms.Label();
            this.lblPlanQtyN = new SmartDas.Components.MESLabel();
            this.lblOrderDateN = new SmartDas.Components.MESLabel();
            this.lblOrderSeqN = new SmartDas.Components.MESLabel();
            this.lblItemSpecN = new SmartDas.Components.MESLabel();
            this.label12 = new System.Windows.Forms.Label();
            this.label13 = new System.Windows.Forms.Label();
            this.lblItemCodeN = new SmartDas.Components.MESLabel();
            this.label14 = new System.Windows.Forms.Label();
            this.lblPaperWidthN = new SmartDas.Components.MESLabel();
            this.label8 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.lblOrderRemark = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblOrderNo = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblPlanQty = new SmartDas.Components.MESLabel();
            this.lblOrderDate = new SmartDas.Components.MESLabel();
            this.lblOrderSeq = new SmartDas.Components.MESLabel();
            this.lblItemSpec = new SmartDas.Components.MESLabel();
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
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(9, 66);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(165, 45);
            this.label2.TabIndex = 49;
            this.label2.Text = "생산요청일";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblItemCode
            // 
            this.lblItemCode.BackColor = System.Drawing.Color.White;
            this.lblItemCode.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblItemCode.ColorContent = System.Drawing.Color.Transparent;
            this.lblItemCode.ColorLabel = System.Drawing.Color.White;
            this.lblItemCode.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblItemCode.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblItemCode.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblItemCode.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblItemCode.Location = new System.Drawing.Point(181, 164);
            this.lblItemCode.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblItemCode.MoveControl = null;
            this.lblItemCode.Name = "lblItemCode";
            this.lblItemCode.Size = new System.Drawing.Size(670, 45);
            this.lblItemCode.TabIndex = 52;
            this.lblItemCode.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblItemCode.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(9, 164);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(165, 45);
            this.label1.TabIndex = 51;
            this.label1.Text = "품목/규격";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPaperWidth
            // 
            this.lblPaperWidth.BackColor = System.Drawing.Color.White;
            this.lblPaperWidth.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPaperWidth.ColorContent = System.Drawing.Color.Transparent;
            this.lblPaperWidth.ColorLabel = System.Drawing.Color.White;
            this.lblPaperWidth.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPaperWidth.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPaperWidth.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPaperWidth.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPaperWidth.Location = new System.Drawing.Point(181, 212);
            this.lblPaperWidth.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPaperWidth.MoveControl = null;
            this.lblPaperWidth.Name = "lblPaperWidth";
            this.lblPaperWidth.Size = new System.Drawing.Size(1085, 45);
            this.lblPaperWidth.TabIndex = 55;
            this.lblPaperWidth.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPaperWidth.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(9, 212);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(165, 45);
            this.label3.TabIndex = 54;
            this.label3.Text = "지폭";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.splitContainer1.Panel1.Controls.Add(this.lblDispoQty);
            this.splitContainer1.Panel1.Controls.Add(this.lblProdQty);
            this.splitContainer1.Panel1.Controls.Add(this.lblTotalQty);
            this.splitContainer1.Panel1.Controls.Add(this.lblDispoHead);
            this.splitContainer1.Panel1.Controls.Add(this.lblProdHead);
            this.splitContainer1.Panel1.Controls.Add(this.lblTotalHead);
            this.splitContainer1.Panel1.Controls.Add(this.butStartDateN);
            this.splitContainer1.Panel1.Controls.Add(this.butEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.butStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.dtpStartDateN);
            this.splitContainer1.Panel1.Controls.Add(this.lblStartTimeN);
            this.splitContainer1.Panel1.Controls.Add(this.label25);
            this.splitContainer1.Panel1.Controls.Add(this.dtpEndDate);
            this.splitContainer1.Panel1.Controls.Add(this.dtpStartDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblEndTime);
            this.splitContainer1.Panel1.Controls.Add(this.label24);
            this.splitContainer1.Panel1.Controls.Add(this.lblStartTime);
            this.splitContainer1.Panel1.Controls.Add(this.label23);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.lblOrderRemarkN);
            this.splitContainer1.Panel1.Controls.Add(this.label10);
            this.splitContainer1.Panel1.Controls.Add(this.lblOrderNoN);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.lblPlanQtyN);
            this.splitContainer1.Panel1.Controls.Add(this.lblOrderDateN);
            this.splitContainer1.Panel1.Controls.Add(this.lblOrderSeqN);
            this.splitContainer1.Panel1.Controls.Add(this.lblItemSpecN);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.label13);
            this.splitContainer1.Panel1.Controls.Add(this.lblItemCodeN);
            this.splitContainer1.Panel1.Controls.Add(this.label14);
            this.splitContainer1.Panel1.Controls.Add(this.lblPaperWidthN);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lblOrderRemark);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblOrderNo);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblPlanQty);
            this.splitContainer1.Panel1.Controls.Add(this.lblOrderDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblOrderSeq);
            this.splitContainer1.Panel1.Controls.Add(this.lblItemSpec);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblItemCode);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblPaperWidth);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblDispoQty
            // 
            this.lblDispoQty.BackColor = System.Drawing.Color.White;
            this.lblDispoQty.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblDispoQty.ColorContent = System.Drawing.Color.Transparent;
            this.lblDispoQty.ColorLabel = System.Drawing.Color.White;
            this.lblDispoQty.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblDispoQty.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblDispoQty.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblDispoQty.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblDispoQty.Location = new System.Drawing.Point(1064, 362);
            this.lblDispoQty.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblDispoQty.MoveControl = null;
            this.lblDispoQty.Name = "lblDispoQty";
            this.lblDispoQty.Size = new System.Drawing.Size(200, 45);
            this.lblDispoQty.TabIndex = 278;
            this.lblDispoQty.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblDispoQty.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblDispoQty.Click += new System.EventHandler(this.lblQty_Click);
            // 
            // lblProdQty
            // 
            this.lblProdQty.BackColor = System.Drawing.Color.White;
            this.lblProdQty.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblProdQty.ColorContent = System.Drawing.Color.Transparent;
            this.lblProdQty.ColorLabel = System.Drawing.Color.White;
            this.lblProdQty.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblProdQty.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblProdQty.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblProdQty.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblProdQty.Location = new System.Drawing.Point(857, 362);
            this.lblProdQty.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblProdQty.MoveControl = null;
            this.lblProdQty.Name = "lblProdQty";
            this.lblProdQty.Size = new System.Drawing.Size(200, 45);
            this.lblProdQty.TabIndex = 277;
            this.lblProdQty.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblProdQty.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblProdQty.Click += new System.EventHandler(this.lblQty_Click);
            // 
            // lblTotalQty
            // 
            this.lblTotalQty.BackColor = System.Drawing.Color.White;
            this.lblTotalQty.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTotalQty.ColorContent = System.Drawing.Color.Transparent;
            this.lblTotalQty.ColorLabel = System.Drawing.Color.White;
            this.lblTotalQty.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTotalQty.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTotalQty.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTotalQty.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTotalQty.Location = new System.Drawing.Point(650, 362);
            this.lblTotalQty.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTotalQty.MoveControl = null;
            this.lblTotalQty.Name = "lblTotalQty";
            this.lblTotalQty.Size = new System.Drawing.Size(200, 45);
            this.lblTotalQty.TabIndex = 276;
            this.lblTotalQty.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTotalQty.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblTotalQty.Click += new System.EventHandler(this.lblQty_Click);
            // 
            // lblDispoHead
            // 
            this.lblDispoHead.BackColor = System.Drawing.Color.Black;
            this.lblDispoHead.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblDispoHead.ForeColor = System.Drawing.Color.White;
            this.lblDispoHead.Location = new System.Drawing.Point(1064, 312);
            this.lblDispoHead.Name = "lblDispoHead";
            this.lblDispoHead.Size = new System.Drawing.Size(200, 45);
            this.lblDispoHead.TabIndex = 275;
            this.lblDispoHead.Text = "폐품중량";
            this.lblDispoHead.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblProdHead
            // 
            this.lblProdHead.BackColor = System.Drawing.Color.Black;
            this.lblProdHead.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblProdHead.ForeColor = System.Drawing.Color.White;
            this.lblProdHead.Location = new System.Drawing.Point(857, 312);
            this.lblProdHead.Name = "lblProdHead";
            this.lblProdHead.Size = new System.Drawing.Size(200, 45);
            this.lblProdHead.TabIndex = 274;
            this.lblProdHead.Text = "완제품생산중량";
            this.lblProdHead.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTotalHead
            // 
            this.lblTotalHead.BackColor = System.Drawing.Color.Black;
            this.lblTotalHead.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTotalHead.ForeColor = System.Drawing.Color.White;
            this.lblTotalHead.Location = new System.Drawing.Point(650, 312);
            this.lblTotalHead.Name = "lblTotalHead";
            this.lblTotalHead.Size = new System.Drawing.Size(200, 45);
            this.lblTotalHead.TabIndex = 273;
            this.lblTotalHead.Text = "투입중량";
            this.lblTotalHead.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // butStartDateN
            // 
            this.butStartDateN.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butStartDateN.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butStartDateN.CausesValidation = false;
            this.butStartDateN.FlatAppearance.BorderSize = 0;
            this.butStartDateN.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butStartDateN.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butStartDateN.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butStartDateN.Location = new System.Drawing.Point(359, 728);
            this.butStartDateN.Name = "butStartDateN";
            this.butStartDateN.Size = new System.Drawing.Size(40, 40);
            this.butStartDateN.TabIndex = 272;
            this.butStartDateN.UseVisualStyleBackColor = false;
            this.butStartDateN.Click += new System.EventHandler(this.butStartDateN_Click);
            // 
            // butEndDate
            // 
            this.butEndDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butEndDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butEndDate.CausesValidation = false;
            this.butEndDate.FlatAppearance.BorderSize = 0;
            this.butEndDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butEndDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butEndDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butEndDate.Location = new System.Drawing.Point(359, 364);
            this.butEndDate.Name = "butEndDate";
            this.butEndDate.Size = new System.Drawing.Size(40, 40);
            this.butEndDate.TabIndex = 271;
            this.butEndDate.UseVisualStyleBackColor = false;
            this.butEndDate.Click += new System.EventHandler(this.butEndDate_Click);
            // 
            // butStartDate
            // 
            this.butStartDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butStartDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butStartDate.CausesValidation = false;
            this.butStartDate.FlatAppearance.BorderSize = 0;
            this.butStartDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butStartDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butStartDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butStartDate.Location = new System.Drawing.Point(359, 314);
            this.butStartDate.Name = "butStartDate";
            this.butStartDate.Size = new System.Drawing.Size(40, 40);
            this.butStartDate.TabIndex = 270;
            this.butStartDate.UseVisualStyleBackColor = false;
            this.butStartDate.Click += new System.EventHandler(this.butStartDate_Click);
            // 
            // dtpStartDateN
            // 
            this.dtpStartDateN.CustomFormat = "yyyy-MM-dd";
            this.dtpStartDateN.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold);
            this.dtpStartDateN.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpStartDateN.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpStartDateN.Location = new System.Drawing.Point(181, 726);
            this.dtpStartDateN.MinimumSize = new System.Drawing.Size(0, 45);
            this.dtpStartDateN.Name = "dtpStartDateN";
            this.dtpStartDateN.ShowUpDown = true;
            this.dtpStartDateN.Size = new System.Drawing.Size(220, 45);
            this.dtpStartDateN.TabIndex = 269;
            this.dtpStartDateN.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // lblStartTimeN
            // 
            this.lblStartTimeN.BackColor = System.Drawing.Color.White;
            this.lblStartTimeN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblStartTimeN.ColorContent = System.Drawing.Color.Transparent;
            this.lblStartTimeN.ColorLabel = System.Drawing.Color.White;
            this.lblStartTimeN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblStartTimeN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblStartTimeN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblStartTimeN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblStartTimeN.Location = new System.Drawing.Point(411, 726);
            this.lblStartTimeN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblStartTimeN.MoveControl = null;
            this.lblStartTimeN.Name = "lblStartTimeN";
            this.lblStartTimeN.Size = new System.Drawing.Size(120, 45);
            this.lblStartTimeN.TabIndex = 268;
            this.lblStartTimeN.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblStartTimeN.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblStartTimeN.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label25
            // 
            this.label25.BackColor = System.Drawing.Color.Black;
            this.label25.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label25.ForeColor = System.Drawing.Color.White;
            this.label25.Location = new System.Drawing.Point(9, 726);
            this.label25.Name = "label25";
            this.label25.Size = new System.Drawing.Size(165, 45);
            this.label25.TabIndex = 267;
            this.label25.Text = "작업시작일시";
            this.label25.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // dtpEndDate
            // 
            this.dtpEndDate.CustomFormat = "yyyy-MM-dd";
            this.dtpEndDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold);
            this.dtpEndDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpEndDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpEndDate.Location = new System.Drawing.Point(181, 362);
            this.dtpEndDate.MinimumSize = new System.Drawing.Size(0, 45);
            this.dtpEndDate.Name = "dtpEndDate";
            this.dtpEndDate.ShowUpDown = true;
            this.dtpEndDate.Size = new System.Drawing.Size(220, 45);
            this.dtpEndDate.TabIndex = 266;
            this.dtpEndDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // dtpStartDate
            // 
            this.dtpStartDate.CustomFormat = "yyyy-MM-dd";
            this.dtpStartDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold);
            this.dtpStartDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpStartDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpStartDate.Location = new System.Drawing.Point(181, 312);
            this.dtpStartDate.MinimumSize = new System.Drawing.Size(0, 45);
            this.dtpStartDate.Name = "dtpStartDate";
            this.dtpStartDate.ShowUpDown = true;
            this.dtpStartDate.Size = new System.Drawing.Size(220, 45);
            this.dtpStartDate.TabIndex = 265;
            this.dtpStartDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // lblEndTime
            // 
            this.lblEndTime.BackColor = System.Drawing.Color.White;
            this.lblEndTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblEndTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblEndTime.ColorLabel = System.Drawing.Color.White;
            this.lblEndTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblEndTime.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblEndTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblEndTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblEndTime.Location = new System.Drawing.Point(411, 362);
            this.lblEndTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblEndTime.MoveControl = null;
            this.lblEndTime.Name = "lblEndTime";
            this.lblEndTime.Size = new System.Drawing.Size(120, 45);
            this.lblEndTime.TabIndex = 264;
            this.lblEndTime.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblEndTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblEndTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label24
            // 
            this.label24.BackColor = System.Drawing.Color.Black;
            this.label24.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label24.ForeColor = System.Drawing.Color.White;
            this.label24.Location = new System.Drawing.Point(9, 362);
            this.label24.Name = "label24";
            this.label24.Size = new System.Drawing.Size(165, 45);
            this.label24.TabIndex = 263;
            this.label24.Text = "작업종료일시";
            this.label24.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblStartTime
            // 
            this.lblStartTime.BackColor = System.Drawing.Color.White;
            this.lblStartTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblStartTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblStartTime.ColorLabel = System.Drawing.Color.White;
            this.lblStartTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblStartTime.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblStartTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblStartTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblStartTime.Location = new System.Drawing.Point(411, 312);
            this.lblStartTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblStartTime.MoveControl = null;
            this.lblStartTime.Name = "lblStartTime";
            this.lblStartTime.Size = new System.Drawing.Size(120, 45);
            this.lblStartTime.TabIndex = 262;
            this.lblStartTime.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblStartTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblStartTime.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // label23
            // 
            this.label23.BackColor = System.Drawing.Color.Black;
            this.label23.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label23.ForeColor = System.Drawing.Color.White;
            this.label23.Location = new System.Drawing.Point(9, 312);
            this.label23.Name = "label23";
            this.label23.Size = new System.Drawing.Size(165, 45);
            this.label23.TabIndex = 261;
            this.label23.Text = "작업시작일시";
            this.label23.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Gray;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(9, 677);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(165, 45);
            this.label9.TabIndex = 156;
            this.label9.Text = "비고";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblOrderRemarkN
            // 
            this.lblOrderRemarkN.BackColor = System.Drawing.Color.White;
            this.lblOrderRemarkN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblOrderRemarkN.ColorContent = System.Drawing.Color.Transparent;
            this.lblOrderRemarkN.ColorLabel = System.Drawing.Color.White;
            this.lblOrderRemarkN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblOrderRemarkN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblOrderRemarkN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblOrderRemarkN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblOrderRemarkN.Location = new System.Drawing.Point(181, 677);
            this.lblOrderRemarkN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblOrderRemarkN.MoveControl = null;
            this.lblOrderRemarkN.Name = "lblOrderRemarkN";
            this.lblOrderRemarkN.Size = new System.Drawing.Size(1085, 45);
            this.lblOrderRemarkN.TabIndex = 157;
            this.lblOrderRemarkN.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblOrderRemarkN.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label10
            // 
            this.label10.BackColor = System.Drawing.Color.Gray;
            this.label10.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label10.ForeColor = System.Drawing.Color.White;
            this.label10.Location = new System.Drawing.Point(9, 529);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(165, 45);
            this.label10.TabIndex = 154;
            this.label10.Text = "작업지시번호";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblOrderNoN
            // 
            this.lblOrderNoN.BackColor = System.Drawing.Color.White;
            this.lblOrderNoN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblOrderNoN.ColorContent = System.Drawing.Color.Transparent;
            this.lblOrderNoN.ColorLabel = System.Drawing.Color.White;
            this.lblOrderNoN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblOrderNoN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblOrderNoN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblOrderNoN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblOrderNoN.Location = new System.Drawing.Point(181, 530);
            this.lblOrderNoN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblOrderNoN.MoveControl = null;
            this.lblOrderNoN.Name = "lblOrderNoN";
            this.lblOrderNoN.Size = new System.Drawing.Size(480, 45);
            this.lblOrderNoN.TabIndex = 155;
            this.lblOrderNoN.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblOrderNoN.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.Gray;
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.White;
            this.label11.Location = new System.Drawing.Point(859, 480);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(165, 95);
            this.label11.TabIndex = 152;
            this.label11.Text = "계획량";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPlanQtyN
            // 
            this.lblPlanQtyN.BackColor = System.Drawing.Color.White;
            this.lblPlanQtyN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPlanQtyN.ColorContent = System.Drawing.Color.Transparent;
            this.lblPlanQtyN.ColorLabel = System.Drawing.Color.White;
            this.lblPlanQtyN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPlanQtyN.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPlanQtyN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPlanQtyN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPlanQtyN.Location = new System.Drawing.Point(1028, 480);
            this.lblPlanQtyN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPlanQtyN.MoveControl = null;
            this.lblPlanQtyN.Name = "lblPlanQtyN";
            this.lblPlanQtyN.Size = new System.Drawing.Size(240, 95);
            this.lblPlanQtyN.TabIndex = 153;
            this.lblPlanQtyN.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPlanQtyN.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblOrderDateN
            // 
            this.lblOrderDateN.BackColor = System.Drawing.Color.White;
            this.lblOrderDateN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblOrderDateN.ColorContent = System.Drawing.Color.Transparent;
            this.lblOrderDateN.ColorLabel = System.Drawing.Color.White;
            this.lblOrderDateN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblOrderDateN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblOrderDateN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblOrderDateN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblOrderDateN.Location = new System.Drawing.Point(181, 480);
            this.lblOrderDateN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblOrderDateN.MoveControl = null;
            this.lblOrderDateN.Name = "lblOrderDateN";
            this.lblOrderDateN.Size = new System.Drawing.Size(670, 45);
            this.lblOrderDateN.TabIndex = 151;
            this.lblOrderDateN.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblOrderDateN.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblOrderSeqN
            // 
            this.lblOrderSeqN.BackColor = System.Drawing.Color.White;
            this.lblOrderSeqN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblOrderSeqN.ColorContent = System.Drawing.Color.Transparent;
            this.lblOrderSeqN.ColorLabel = System.Drawing.Color.White;
            this.lblOrderSeqN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblOrderSeqN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblOrderSeqN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblOrderSeqN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblOrderSeqN.Location = new System.Drawing.Point(671, 530);
            this.lblOrderSeqN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblOrderSeqN.MoveControl = null;
            this.lblOrderSeqN.Name = "lblOrderSeqN";
            this.lblOrderSeqN.Size = new System.Drawing.Size(180, 45);
            this.lblOrderSeqN.TabIndex = 150;
            this.lblOrderSeqN.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblOrderSeqN.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblItemSpecN
            // 
            this.lblItemSpecN.BackColor = System.Drawing.Color.White;
            this.lblItemSpecN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblItemSpecN.ColorContent = System.Drawing.Color.Transparent;
            this.lblItemSpecN.ColorLabel = System.Drawing.Color.White;
            this.lblItemSpecN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblItemSpecN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblItemSpecN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblItemSpecN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblItemSpecN.Location = new System.Drawing.Point(861, 579);
            this.lblItemSpecN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblItemSpecN.MoveControl = null;
            this.lblItemSpecN.Name = "lblItemSpecN";
            this.lblItemSpecN.Size = new System.Drawing.Size(405, 45);
            this.lblItemSpecN.TabIndex = 149;
            this.lblItemSpecN.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblItemSpecN.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label12
            // 
            this.label12.BackColor = System.Drawing.Color.Gray;
            this.label12.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label12.ForeColor = System.Drawing.Color.White;
            this.label12.Location = new System.Drawing.Point(9, 480);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(165, 45);
            this.label12.TabIndex = 144;
            this.label12.Text = "생산요청일";
            this.label12.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label13
            // 
            this.label13.BackColor = System.Drawing.Color.Gray;
            this.label13.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label13.ForeColor = System.Drawing.Color.White;
            this.label13.Location = new System.Drawing.Point(9, 579);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(165, 45);
            this.label13.TabIndex = 145;
            this.label13.Text = "품목/규격";
            this.label13.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblItemCodeN
            // 
            this.lblItemCodeN.BackColor = System.Drawing.Color.White;
            this.lblItemCodeN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblItemCodeN.ColorContent = System.Drawing.Color.Transparent;
            this.lblItemCodeN.ColorLabel = System.Drawing.Color.White;
            this.lblItemCodeN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblItemCodeN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblItemCodeN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblItemCodeN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblItemCodeN.Location = new System.Drawing.Point(181, 579);
            this.lblItemCodeN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblItemCodeN.MoveControl = null;
            this.lblItemCodeN.Name = "lblItemCodeN";
            this.lblItemCodeN.Size = new System.Drawing.Size(670, 45);
            this.lblItemCodeN.TabIndex = 146;
            this.lblItemCodeN.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblItemCodeN.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label14
            // 
            this.label14.BackColor = System.Drawing.Color.Gray;
            this.label14.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label14.ForeColor = System.Drawing.Color.White;
            this.label14.Location = new System.Drawing.Point(9, 628);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(165, 45);
            this.label14.TabIndex = 147;
            this.label14.Text = "지폭";
            this.label14.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPaperWidthN
            // 
            this.lblPaperWidthN.BackColor = System.Drawing.Color.White;
            this.lblPaperWidthN.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPaperWidthN.ColorContent = System.Drawing.Color.Transparent;
            this.lblPaperWidthN.ColorLabel = System.Drawing.Color.White;
            this.lblPaperWidthN.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPaperWidthN.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPaperWidthN.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPaperWidthN.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPaperWidthN.Location = new System.Drawing.Point(181, 628);
            this.lblPaperWidthN.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPaperWidthN.MoveControl = null;
            this.lblPaperWidthN.Name = "lblPaperWidthN";
            this.lblPaperWidthN.Size = new System.Drawing.Size(1085, 45);
            this.lblPaperWidthN.TabIndex = 148;
            this.lblPaperWidthN.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPaperWidthN.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.Red;
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.White;
            this.label8.Location = new System.Drawing.Point(9, 427);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(1260, 50);
            this.label8.TabIndex = 143;
            this.label8.Text = "이후 작업지시";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Green;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(9, 13);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(1260, 50);
            this.label7.TabIndex = 142;
            this.label7.Text = "이전 작업지시";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(9, 260);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(165, 45);
            this.label6.TabIndex = 140;
            this.label6.Text = "비고";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblOrderRemark
            // 
            this.lblOrderRemark.BackColor = System.Drawing.Color.White;
            this.lblOrderRemark.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblOrderRemark.ColorContent = System.Drawing.Color.Transparent;
            this.lblOrderRemark.ColorLabel = System.Drawing.Color.White;
            this.lblOrderRemark.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblOrderRemark.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblOrderRemark.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblOrderRemark.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblOrderRemark.Location = new System.Drawing.Point(181, 260);
            this.lblOrderRemark.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblOrderRemark.MoveControl = null;
            this.lblOrderRemark.Name = "lblOrderRemark";
            this.lblOrderRemark.Size = new System.Drawing.Size(1085, 45);
            this.lblOrderRemark.TabIndex = 141;
            this.lblOrderRemark.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblOrderRemark.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Gray;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(9, 115);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(165, 45);
            this.label5.TabIndex = 138;
            this.label5.Text = "작업지시번호";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblOrderNo
            // 
            this.lblOrderNo.BackColor = System.Drawing.Color.White;
            this.lblOrderNo.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblOrderNo.ColorContent = System.Drawing.Color.Transparent;
            this.lblOrderNo.ColorLabel = System.Drawing.Color.White;
            this.lblOrderNo.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblOrderNo.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblOrderNo.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblOrderNo.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblOrderNo.Location = new System.Drawing.Point(181, 115);
            this.lblOrderNo.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblOrderNo.MoveControl = null;
            this.lblOrderNo.Name = "lblOrderNo";
            this.lblOrderNo.Size = new System.Drawing.Size(480, 45);
            this.lblOrderNo.TabIndex = 139;
            this.lblOrderNo.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblOrderNo.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(859, 66);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(165, 95);
            this.label4.TabIndex = 136;
            this.label4.Text = "계획량";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblPlanQty
            // 
            this.lblPlanQty.BackColor = System.Drawing.Color.White;
            this.lblPlanQty.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPlanQty.ColorContent = System.Drawing.Color.Transparent;
            this.lblPlanQty.ColorLabel = System.Drawing.Color.White;
            this.lblPlanQty.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPlanQty.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPlanQty.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPlanQty.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPlanQty.Location = new System.Drawing.Point(1028, 66);
            this.lblPlanQty.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPlanQty.MoveControl = null;
            this.lblPlanQty.Name = "lblPlanQty";
            this.lblPlanQty.Size = new System.Drawing.Size(240, 95);
            this.lblPlanQty.TabIndex = 137;
            this.lblPlanQty.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblPlanQty.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblOrderDate
            // 
            this.lblOrderDate.BackColor = System.Drawing.Color.White;
            this.lblOrderDate.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblOrderDate.ColorContent = System.Drawing.Color.Transparent;
            this.lblOrderDate.ColorLabel = System.Drawing.Color.White;
            this.lblOrderDate.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblOrderDate.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblOrderDate.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblOrderDate.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblOrderDate.Location = new System.Drawing.Point(181, 66);
            this.lblOrderDate.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblOrderDate.MoveControl = null;
            this.lblOrderDate.Name = "lblOrderDate";
            this.lblOrderDate.Size = new System.Drawing.Size(670, 45);
            this.lblOrderDate.TabIndex = 135;
            this.lblOrderDate.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblOrderDate.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblOrderSeq
            // 
            this.lblOrderSeq.BackColor = System.Drawing.Color.White;
            this.lblOrderSeq.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblOrderSeq.ColorContent = System.Drawing.Color.Transparent;
            this.lblOrderSeq.ColorLabel = System.Drawing.Color.White;
            this.lblOrderSeq.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblOrderSeq.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblOrderSeq.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblOrderSeq.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblOrderSeq.Location = new System.Drawing.Point(671, 115);
            this.lblOrderSeq.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblOrderSeq.MoveControl = null;
            this.lblOrderSeq.Name = "lblOrderSeq";
            this.lblOrderSeq.Size = new System.Drawing.Size(180, 45);
            this.lblOrderSeq.TabIndex = 134;
            this.lblOrderSeq.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblOrderSeq.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblItemSpec
            // 
            this.lblItemSpec.BackColor = System.Drawing.Color.White;
            this.lblItemSpec.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblItemSpec.ColorContent = System.Drawing.Color.Transparent;
            this.lblItemSpec.ColorLabel = System.Drawing.Color.White;
            this.lblItemSpec.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblItemSpec.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblItemSpec.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblItemSpec.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblItemSpec.Location = new System.Drawing.Point(861, 164);
            this.lblItemSpec.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblItemSpec.MoveControl = null;
            this.lblItemSpec.Name = "lblItemSpec";
            this.lblItemSpec.Size = new System.Drawing.Size(405, 45);
            this.lblItemSpec.TabIndex = 128;
            this.lblItemSpec.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblItemSpec.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK41
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK41";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK41_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label2;
        private MESLabel lblPaperWidth;
        private System.Windows.Forms.Label label3;
        private MESLabel lblItemCode;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESLabel lblItemSpec;
        private MESLabel lblOrderSeq;
        private System.Windows.Forms.Label label5;
        private MESLabel lblOrderNo;
        private System.Windows.Forms.Label label4;
        private MESLabel lblPlanQty;
        private MESLabel lblOrderDate;
        private System.Windows.Forms.Label label6;
        private MESLabel lblOrderRemark;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label9;
        private MESLabel lblOrderRemarkN;
        private System.Windows.Forms.Label label10;
        private MESLabel lblOrderNoN;
        private System.Windows.Forms.Label label11;
        private MESLabel lblPlanQtyN;
        private MESLabel lblOrderDateN;
        private MESLabel lblOrderSeqN;
        private MESLabel lblItemSpecN;
        private System.Windows.Forms.Label label12;
        private System.Windows.Forms.Label label13;
        private MESLabel lblItemCodeN;
        private System.Windows.Forms.Label label14;
        private MESLabel lblPaperWidthN;
        private System.Windows.Forms.DateTimePicker dtpStartDateN;
        private MESLabel lblStartTimeN;
        private System.Windows.Forms.Label label25;
        private System.Windows.Forms.DateTimePicker dtpEndDate;
        private System.Windows.Forms.DateTimePicker dtpStartDate;
        private MESLabel lblEndTime;
        private System.Windows.Forms.Label label24;
        private MESLabel lblStartTime;
        private System.Windows.Forms.Label label23;
        private System.Windows.Forms.Button butStartDateN;
        private System.Windows.Forms.Button butEndDate;
        private System.Windows.Forms.Button butStartDate;
        private MESLabel lblDispoQty;
        private MESLabel lblProdQty;
        private MESLabel lblTotalQty;
        private System.Windows.Forms.Label lblDispoHead;
        private System.Windows.Forms.Label lblProdHead;
        private System.Windows.Forms.Label lblTotalHead;

    }
}
