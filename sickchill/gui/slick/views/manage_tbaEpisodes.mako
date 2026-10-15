<%inherit file="/layouts/main.mako" />
<%!
    import datetime

    from sickchill.helper import episode_num
    from sickchill.oldbeard import scdatetime
%>

<%def name="hidden_shows(show_ids)">
    % for show_id in show_ids:
        <input type="hidden" name="show" value="${show_id}" />
    % endfor
</%def>

<%block name="content">
    <%
    # issue -> (row/badge css class, label)
    issue_styles = {
        'tba': ('wanted', _('TBA title')),
        'rename': ('snatched', _('Named TBA')),
        'quality': ('qual', _('Unknown quality')),
    }
    tba_shows = [item['show'].indexerid for item in shows if item['counts']['tba']]
    rename_shows = [item['show'].indexerid for item in shows if item['counts']['rename'] or item['counts']['quality']]
    quality_shows = [item['show'].indexerid for item in shows if item['counts']['quality']]
    %>
    <div class="row">
        <div class="col-lg-8 col-md-7 col-sm-6 col-xs-12 pull-right">
            <div class="pull-right">
                % for issue in ('tba', 'rename', 'quality'):
                    % if totals[issue] > 0:
                        <span class="listing-key ${issue_styles[issue][0]}">${issue_styles[issue][1]}: <b>${totals[issue]}</b></span>
                    % endif
                % endfor
            </div>
        </div>
        <div class="col-lg-4 col-md-5 col-sm-6 col-xs-12">
            % if not header is UNDEFINED:
                <h1 class="header">${header}</h1>
            % else:
                <h1 class="title">${title}</h1>
            % endif
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <p>
                <span class="listing-key wanted">${_('TBA title')}</span> ${_('still titled TBA (airing up to 7 days ahead): Update TBA names')}
                &nbsp; <span class="listing-key snatched">${_('Named TBA')}</span> ${_('file still named after a TBA title: Preview rename')}
                &nbsp; <span class="listing-key qual">${_('Unknown quality')}</span> ${_('renames as "Unknown": Fix quality, then Preview rename')}
            </p>
            % if quality_fix_running:
                <p><strong>${_('A quality fix is running. Reload this page when it finishes.')}</strong></p>
            % endif
        </div>
    </div>

    % if not shows:
        <div class="row">
            <div class="col-md-12">
                <h3>${_('Nothing to fix: no TBA titles, TBA-named files or unknown qualities.')}</h3>
            </div>
        </div>
    % else:
        <div class="row">
            <div class="col-md-12">
                % if tba_shows:
                    <form method="post" action="${scRoot}/manage/tbaUpdate" style="display: inline-block;">
                        ${hidden_shows(tba_shows)}
                        <input type="submit" class="btn btn-inline" value="${_('Update all TBA names')} (${len(tba_shows)})" />
                    </form>
                % endif
                % if quality_shows:
                    <form method="post" action="${scRoot}/manage/qualityFix" style="display: inline-block;">
                        ${hidden_shows(quality_shows)}
                        <input type="submit" class="btn btn-inline" value="${_('Fix quality for all')} (${len(quality_shows)})" ${('', 'disabled')[quality_fix_running]} />
                    </form>
                % endif
                % if rename_shows:
                    <form method="post" action="${scRoot}/manage/massRenamePreview" style="display: inline-block;">
                        <input type="hidden" name="next" value="tba" />
                        ${hidden_shows(rename_shows)}
                        <input type="submit" class="btn btn-inline" value="${_('Preview rename for all')} (${len(rename_shows)})" />
                    </form>
                % endif
                <a href="${scRoot}/manage/tbaEpisodes/" class="btn btn-inline">${_('Reload')}</a>
            </div>
        </div>
        <br/>
        <div class="row">
            <div class="col-md-12">
                <label for="pickShow">${_('Jump to Show')}:</label>
                <select id="pickShow" class="form-control form-control-inline input-sm">
                    % for item in shows:
                        <option value="${item['show'].indexerid}">${item['show'].name}</option>
                    % endfor
                </select>
            </div>
        </div>

        % for item in shows:
            <% show = item['show'] %>
            <div class="row">
                <div class="col-md-12">
                    <div class="pull-right" style="margin-top: 30px;">
                        % if item['state']:
                            <span class="listing-key good">${item['state']}</span>
                        % endif
                        % for issue in ('tba', 'rename', 'quality'):
                            % if item['counts'][issue] > 0:
                                <span class="listing-key ${issue_styles[issue][0]}">${issue_styles[issue][1]}: <b>${item['counts'][issue]}</b></span>
                            % endif
                        % endfor
                        % if item['counts']['tba']:
                            <a class="btn btn-inline" href="${scRoot}/manage/tbaUpdate?show=${show.indexerid}">${_('Update TBA names')}</a>
                        % endif
                        % if item['counts']['quality']:
                            <a class="btn btn-inline" href="${scRoot}/manage/qualityFix?show=${show.indexerid}" ${('', 'disabled')[quality_fix_running]}>${_('Fix quality')}</a>
                        % endif
                        % if item['counts']['rename'] or item['counts']['quality']:
                            <a class="btn btn-inline" href="${scRoot}/manage/massRenamePreview?show=${show.indexerid}&amp;next=tba">${_('Preview rename')}</a>
                        % endif
                    </div>

                    <h2 style="display: inline-block;">
                        <a href="${scRoot}/home/displayShow?show=${show.indexerid}">${show.name}</a>
                    </h2>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="horizontal-scroll">
                        <table class="sickchillTable">
                            <tr class="seasonheader" id="show-${show.indexerid}">
                                <td colspan="5" class="align-left" style="position: relative;"></td>
                            </tr>
                            <tr class="seasoncols">
                                <th>${_('Episode')}</th>
                                <th>${_('Name')}</th>
                                <th>${_('File')}</th>
                                <th class="nowrap">${_('Airdate')}</th>
                                <th class="nowrap">${_('Issue')}</th>
                            </tr>
                            % for row in item['rows']:
                                <tr class="seasonstyle ${issue_styles[row['issues'][0]][0]}">
                                    <td class="tableleft text-center">${episode_num(row['season'], row['episode'])}</td>
                                    <td class="text-center nowrap">${row['name']}</td>
                                    <td class="text-center">${row['file']}</td>
                                    <td class="text-center nowrap">
                                        % if row['airdate'] > 1:
                                            ${scdatetime.scdatetime.scfdate(datetime.date.fromordinal(row['airdate']))}
                                        % else:
                                            ${_('Never')}
                                        % endif
                                    </td>
                                    <td class="text-center nowrap">${', '.join(issue_styles[issue][1] for issue in row['issues'])}</td>
                                </tr>
                            % endfor
                        </table>
                    </div>
                </div>
            </div>
        % endfor
    % endif
</%block>
