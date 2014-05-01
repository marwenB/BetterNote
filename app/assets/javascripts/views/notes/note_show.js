BetterNote.Views.NoteShow = Backbone.View.extend({
  initialize: function() {
    this.listenTo(this.model, "add change remove", this.render);
    this.listenTo(this.model.notebook, "change", this.render);
  },

  template: JST['notes/show'],

  events: {
    "click .dropdown-parent": "showDropdown",
    "click .options-dropdown, .dropdown-parent": "stopPropagation",
    "click form.update-notebook": "updateNotebook"
  },

  render: function() {
    var renderedContent = this.template({
      note: this.model,
      notebooks: BetterNote.notebooks
    });
    BetterNote.featuredNote = this.model;

    $("body").on("click", this.hideDropdowns);

    this.$el.html(renderedContent);

    var commentView = new BetterNote.Views.CommentsIndex({
      collection: this.model.comments,
      note: this.model
    });

    this.$el.append(commentView.render().$el);

    return this;
  },

  showDropdown: function(event) {
    event.preventDefault();
    this.hideDropdowns();

    var $dropdown = $(event.currentTarget).find(".options-dropdown");
    $dropdown.removeClass("hidden");
  },

  hideDropdowns: function(event) {
    $(".options-dropdown").not("hidden").addClass("hidden");
  },

  stopPropagation: function(event) {
    event.stopPropagation();
  },

  updateNotebook: function(event) {
    event.preventDefault();

    var that = this;
    var attrs = $(event.currentTarget).serializeJSON();
    var success = function() {
      that.hideDropdowns();
    };

    var oldNotebook = that.model.notebook;
    var newNotebook = BetterNote.notebooks.get(attrs.note.notebook_id);
    this.model.notebook = newNotebook;
    oldNotebook.notes.remove(this.model);
    newNotebook.notes.add(this.model);

    this.model.set(attrs);
    this.model.save({}, {
      success: success
    })
  }
});