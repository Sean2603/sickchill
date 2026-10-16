$(document).ready(() => {
    $('#massRenameAll').on('click', function () {
        const checked = this.checked;

        $('.massRenameShowCheck:visible, .massRenameEp:visible').each(function () {
            this.checked = checked;
        });
    });

    $('.massRenameShowCheck').on('click', function () {
        const checked = this.checked;

        $('.massRenameEp.show-' + $(this).data('show') + ':visible').each(function () {
            this.checked = checked;
        });
    });

    $('#massRenameTbaOnly').on('change', function () {
        const tbaOnly = this.checked;

        $('.massRenameRow').each(function () {
            const row = $(this);
            const hide = tbaOnly && row.data('tba') !== 1;
            row.toggle(!hide);
            if (hide) {
                row.find('.massRenameEp').prop('checked', false);
            }
        });

        $('.massRenameShow').each(function () {
            const show = $(this);
            show.toggle(!tbaOnly || show.find('.massRenameRow[data-tba="1"]').length > 0);
        });
    });

    $('.massRenameSubmit').on('click', () => $('.massRenameEp:checked').length > 0);
});
